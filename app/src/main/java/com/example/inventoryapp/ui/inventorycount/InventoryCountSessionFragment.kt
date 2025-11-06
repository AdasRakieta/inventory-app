package com.example.inventoryapp.ui.inventorycount

import android.app.AlertDialog
import android.net.Uri
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.LinearLayout
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.example.inventoryapp.databinding.FragmentInventoryCountSessionBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.InventoryCountRepository
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

/**
 * Fragment for viewing/managing an inventory count session.
 * Shows scanned products, statistics, and allows completing the session.
 */
class InventoryCountSessionFragment : Fragment() {

    private var _binding: FragmentInventoryCountSessionBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: InventoryCountSessionViewModel
    
    private val args: InventoryCountSessionFragmentArgs by navArgs()
    
    private var currentInputField: TextInputEditText? = null
    private val scannedSerials = mutableSetOf<String>()

    // CSV file picker launcher
    private val csvPickerLauncher = registerForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let { importCsvFile(it) }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = InventoryCountRepository(
            database.inventoryCountDao(),
            database.productDao()
        )
        val factory = InventoryCountSessionViewModelFactory(repository, args.sessionId)
        val vm: InventoryCountSessionViewModel by viewModels { factory }
        viewModel = vm
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentInventoryCountSessionBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        setupClickListeners()
        observeSession()
        observeProducts()
        observeStatistics()
        
        // Start with one empty input field
        addProductInputField()
    }

    private fun setupClickListeners() {
        binding.completeSessionButton.setOnClickListener {
            showCompleteConfirmationDialog()
        }
        
        binding.clearSessionButton.setOnClickListener {
            showClearConfirmationDialog()
        }
        
        binding.viewStatisticsButton.setOnClickListener {
            showStatisticsDialog()
        }
        
        binding.importCsvButton.setOnClickListener {
            csvPickerLauncher.launch("text/*")
        }
        
        binding.downloadTemplateButton.setOnClickListener {
            downloadCsvTemplate()
        }
    }
    
    private fun addProductInputField() {
        // Reuse existing field if available
        if (binding.productsInputContainer.childCount > 0) {
            currentInputField?.setText("")
            currentInputField?.requestFocus()
            return
        }
        
        val context = requireContext()
        val itemNumber = scannedSerials.size + 1

        // Create horizontal container for input field and delete button
        val horizontalContainer = LinearLayout(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 16
            }
            orientation = LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER_VERTICAL
        }

        // Create TextInputLayout
        val inputLayout = TextInputLayout(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                0, // width = 0 for weight
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f // weight = 1 to take remaining space
            )
            hint = "$itemNumber. Serial Number *"
            setBoxBackgroundMode(TextInputLayout.BOX_BACKGROUND_OUTLINE)
        }

        // Create TextInputEditText
        val editText = TextInputEditText(inputLayout.context).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            maxLines = 1
            imeOptions = EditorInfo.IME_ACTION_DONE

            // Handle enter key
            setOnEditorActionListener { _, actionId, event ->
                if (actionId == EditorInfo.IME_ACTION_DONE ||
                    (event?.action == KeyEvent.ACTION_DOWN && event.keyCode == KeyEvent.KEYCODE_ENTER)) {
                    val serialNumber = text.toString().trim()
                    processManualEntry(serialNumber)
                    true
                } else {
                    false
                }
            }

            // Auto-focus for barcode scanners
            addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                override fun afterTextChanged(s: Editable?) {
                    val text = s.toString().trim()
                    if (text.isNotEmpty() && text.length >= 5) {
                        postDelayed({
                            if (this@apply.text.toString().trim() == text) {
                                processManualEntry(text)
                            }
                        }, 100)
                    }
                }
            })
        }

        // Assemble the layout
        inputLayout.addView(editText)
        horizontalContainer.addView(inputLayout)

        binding.productsInputContainer.addView(horizontalContainer)

        // Store current input field reference
        currentInputField = editText

        // Focus the new field
        editText.requestFocus()
    }
    
    private fun processManualEntry(serialNumber: String) {
        if (serialNumber.isEmpty()) return

        // Check if already scanned in this session
        if (scannedSerials.contains(serialNumber)) {
            Toast.makeText(requireContext(), "⚠️ Already scanned: $serialNumber", Toast.LENGTH_SHORT).show()
            currentInputField?.setText("")
            return
        }

        // Scan product through ViewModel
        viewLifecycleOwner.lifecycleScope.launch {
            val result = viewModel.scanProduct(serialNumber)
            
            // Handle result
            when (result) {
                is com.example.inventoryapp.data.repository.ScanResult.Success -> {
                    Toast.makeText(
                        requireContext(), 
                        "✅ Added: ${result.product.name}", 
                        Toast.LENGTH_SHORT
                    ).show()
                    scannedSerials.add(serialNumber)
                    updateInputFieldHint()
                }
                is com.example.inventoryapp.data.repository.ScanResult.Error -> {
                    Toast.makeText(
                        requireContext(), 
                        "❌ ${result.message}", 
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
            
            // Clear field and prepare for next scan
            currentInputField?.setText("")
            currentInputField?.requestFocus()
        }
    }

    private fun observeSession() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.session.collect { session ->
                session?.let {
                    binding.sessionName.text = it.name
                    binding.sessionStatus.text = it.status
                    
                    val isCompleted = it.status == "COMPLETED"
                    
                    // Show/hide buttons based on status
                    binding.completeSessionButton.visibility = 
                        if (!isCompleted) View.VISIBLE else View.GONE
                    
                    binding.clearSessionButton.visibility = 
                        if (!isCompleted) View.VISIBLE else View.GONE
                    
                    // Disable import/template buttons when completed
                    binding.importCsvButton.isEnabled = !isCompleted
                    binding.downloadTemplateButton.isEnabled = !isCompleted
                    
                    // Show/hide input container (disable adding items when completed)
                    binding.manualEntryContainer.visibility = 
                        if (!isCompleted) View.VISIBLE else View.GONE
                    
                    // Show statistics button when completed
                    binding.viewStatisticsButton.visibility = 
                        if (isCompleted) View.VISIBLE else View.GONE
                }
            }
        }
    }

    private fun observeProducts() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.scannedProducts.collect { products ->
                binding.totalCountText.text = "${products.size} items"
                
                // Update scannedSerials set
                scannedSerials.clear()
                products.forEach { product ->
                    product.serialNumber?.let { scannedSerials.add(it) }
                }
                
                // Update input field hint with current count
                updateInputFieldHint()
            }
        }
    }

    private fun observeStatistics() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.categoryStatistics.collect { stats ->
                if (stats.isEmpty()) {
                    binding.statisticsText.text = "No items scanned"
                } else {
                    // Build compact statistics text
                    val statsText = stats.entries.joinToString(" • ") { (categoryName, count) ->
                        "$categoryName: $count"
                    }
                    binding.statisticsText.text = statsText
                }
            }
        }
    }
    
    private fun updateInputFieldHint() {
        currentInputField?.let { editText ->
            val inputLayout = editText.parent as? TextInputLayout
            inputLayout?.hint = "${scannedSerials.size + 1}. Serial Number *"
        }
    }

    private fun showCompleteConfirmationDialog() {
        AlertDialog.Builder(requireContext())
            .setTitle("Complete Session")
            .setMessage("Mark this session as completed? You won't be able to scan more products.")
            .setPositiveButton("Complete") { _, _ ->
                viewModel.completeSession()
                Toast.makeText(requireContext(), "Session completed", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showClearConfirmationDialog() {
        AlertDialog.Builder(requireContext())
            .setTitle("Clear Session")
            .setMessage("Remove all scanned products from this session?")
            .setPositiveButton("Clear") { _, _ ->
                viewModel.clearSession()
                Toast.makeText(requireContext(), "Session cleared", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showStatisticsDialog() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val statistics = viewModel.getDetailedStatistics()
                
                val dialogView = layoutInflater.inflate(com.example.inventoryapp.R.layout.dialog_inventory_count_statistics, null)
                val dialog = AlertDialog.Builder(requireContext())
                    .setView(dialogView)
                    .create()
                
                val recyclerView = dialogView.findViewById<androidx.recyclerview.widget.RecyclerView>(com.example.inventoryapp.R.id.inventoryStatsRecyclerView)
                val totalCountText = dialogView.findViewById<android.widget.TextView>(com.example.inventoryapp.R.id.totalCountText)
                val closeButton = dialogView.findViewById<android.widget.Button>(com.example.inventoryapp.R.id.closeButton)
                
                val statsAdapter = InventoryCountStatisticsAdapter()
                recyclerView.layoutManager = androidx.recyclerview.widget.LinearLayoutManager(requireContext())
                recyclerView.adapter = statsAdapter
                statsAdapter.submitList(statistics)
                
                val totalCount = statistics.sumOf { it.count }
                totalCountText.text = totalCount.toString()
                
                closeButton.setOnClickListener {
                    dialog.dismiss()
                }
                
                dialog.show()
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error loading statistics: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun downloadCsvTemplate() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Use app-specific external storage
                val templatesDir = java.io.File(requireContext().getExternalFilesDir(null), "inventory/templates")
                
                // Create directory if not exists
                if (!templatesDir.exists()) {
                    templatesDir.mkdirs()
                }
                
                val templateFile = java.io.File(templatesDir, "inventory_count_template.csv")
                
                // CSV Template content
                val templateContent = """Serial Number
EXAMPLE123
EXAMPLE456
EXAMPLE789
""".trimIndent()
                
                // Write to file (overwrite if exists)
                templateFile.writeText(templateContent)
                
                Toast.makeText(
                    requireContext(), 
                    "Template downloaded to:\n${templateFile.absolutePath}", 
                    Toast.LENGTH_LONG
                ).show()
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(), 
                    "Error downloading template: ${e.message}", 
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun importCsvFile(uri: Uri) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val inputStream = requireContext().contentResolver.openInputStream(uri)
                    ?: throw Exception("Cannot open file")
                
                val lines = inputStream.bufferedReader().use { it.readLines() }
                
                if (lines.isEmpty()) {
                    Toast.makeText(requireContext(), "CSV file is empty", Toast.LENGTH_SHORT).show()
                    return@launch
                }
                
                // Skip header row
                val serialNumbers = lines.drop(1).map { it.trim() }.filter { it.isNotEmpty() }
                
                if (serialNumbers.isEmpty()) {
                    Toast.makeText(requireContext(), "No serial numbers found in CSV", Toast.LENGTH_SHORT).show()
                    return@launch
                }
                
                var successCount = 0
                var errorCount = 0
                val errors = mutableListOf<String>()
                
                // Process each serial number
                for (serialNumber in serialNumbers) {
                    // Check if already scanned
                    if (scannedSerials.contains(serialNumber)) {
                        errorCount++
                        errors.add("$serialNumber (already scanned)")
                        continue
                    }
                    
                    val result = viewModel.scanProduct(serialNumber)
                    
                    when (result) {
                        is com.example.inventoryapp.data.repository.ScanResult.Success -> {
                            successCount++
                            scannedSerials.add(serialNumber)
                        }
                        is com.example.inventoryapp.data.repository.ScanResult.Error -> {
                            errorCount++
                            errors.add("$serialNumber (${result.message})")
                        }
                    }
                }
                
                // Show results
                val message = buildString {
                    append("Import completed!\n")
                    append("✅ Success: $successCount\n")
                    if (errorCount > 0) {
                        append("❌ Errors: $errorCount\n\n")
                        append("Failed items:\n")
                        append(errors.take(5).joinToString("\n"))
                        if (errors.size > 5) {
                            append("\n... and ${errors.size - 5} more")
                        }
                    }
                }
                
                AlertDialog.Builder(requireContext())
                    .setTitle("CSV Import Results")
                    .setMessage(message)
                    .setPositiveButton("OK", null)
                    .show()
                
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(), 
                    "Error importing CSV: ${e.message}", 
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
