package com.example.inventoryapp.ui.inventorycount

import android.app.AlertDialog
import android.app.Dialog
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
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.inventoryapp.databinding.DialogPackageSelectionBinding
import com.example.inventoryapp.databinding.FragmentInventoryCountSessionBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.InventoryCountRepository
import com.example.inventoryapp.ui.inventorycount.PackageSelectionAdapter
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
    
    private var currentProducts = emptyList<com.example.inventoryapp.data.local.entities.ProductEntity>()
    
    private lateinit var productsAdapter: InventoryCountProductsAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val database = AppDatabase.getDatabase(requireContext())
        val repository = InventoryCountRepository(
            database.inventoryCountDao(),
            database.productDao()
        )
        val packageRepository = (requireActivity().application as com.example.inventoryapp.InventoryApplication).packageRepository
        val productRepository = (requireActivity().application as com.example.inventoryapp.InventoryApplication).productRepository
        val factory = InventoryCountSessionViewModelFactory(repository, packageRepository, productRepository, args.sessionId)
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

        setupRecyclerView()
        setupClickListeners()
        observeSession()
        observeProducts()
        observeStatistics()
        
        // Start with one empty input field
        addProductInputField()
    }

    private fun setupRecyclerView() {
        productsAdapter = InventoryCountProductsAdapter()
        binding.scannedProductsRecyclerView.apply {
            layoutManager = androidx.recyclerview.widget.LinearLayoutManager(requireContext())
            adapter = productsAdapter
        }
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
        
        binding.bulkAssignButton.setOnClickListener {
            showBulkAssignDialog()
        }
        
        binding.showMissingProductsButton.setOnClickListener {
            showMissingProductsDialog()
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
                    
                    // Show/hide input container (disable adding items when completed)
                    binding.manualEntryContainer.visibility = 
                        if (!isCompleted) View.VISIBLE else View.GONE
                    
                    // Show statistics button when completed
                    binding.viewStatisticsButton.visibility = 
                        if (isCompleted) View.VISIBLE else View.GONE
                    
                    // Update bulk assign button visibility
                    updateBulkAssignButtonVisibility()
                }
            }
        }
    }

    private fun updateBulkAssignButtonVisibility() {
        viewLifecycleOwner.lifecycleScope.launch {
            val session = viewModel.session.value
            val isCompleted = session?.status == "COMPLETED"
            val hasProducts = currentProducts.isNotEmpty()
            
            binding.bulkAssignButton.visibility = 
                if (isCompleted && hasProducts) View.VISIBLE else View.GONE
        }
    }

    private fun observeProducts() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.scannedProducts.collect { products ->
                binding.totalCountText.text = "${products.size} items"
                
                // Update current products list
                currentProducts = products
                
                // Update scannedSerials set
                scannedSerials.clear()
                products.forEach { product ->
                    product.serialNumber?.let { scannedSerials.add(it) }
                }
                
                // Update adapter with products
                productsAdapter.submitList(products)
                
                // Update input field hint with current count
                updateInputFieldHint()
                
                // Update bulk assign button visibility
                updateBulkAssignButtonVisibility()
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

    private fun showBulkAssignDialog() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Get all packages
                val packages = viewModel.getAllPackages()

                if (packages.isEmpty()) {
                    Toast.makeText(requireContext(), "No packages available", Toast.LENGTH_SHORT).show()
                    return@launch
                }

                // Create dialog
                val dialog = Dialog(requireContext())
                val binding = DialogPackageSelectionBinding.inflate(layoutInflater)
                dialog.setContentView(binding.root)

                // Setup RecyclerView
                val adapter = PackageSelectionAdapter { selectedPackage ->
                    // Handle package selection
                    binding.assignButton.isEnabled = true
                }
                binding.packagesRecyclerView.layoutManager = LinearLayoutManager(requireContext())
                binding.packagesRecyclerView.adapter = adapter
                adapter.submitList(packages)

                // Setup search functionality
                binding.searchEditText.addTextChangedListener(object : TextWatcher {
                    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                    override fun afterTextChanged(s: Editable?) {
                        val query = s?.toString()?.trim() ?: ""
                        if (query.isEmpty()) {
                            adapter.submitList(packages)
                        } else {
                            val filteredPackages = packages.filter { pkg ->
                                pkg.name.contains(query, ignoreCase = true) ||
                                pkg.packageCode?.contains(query, ignoreCase = true) == true ||
                                pkg.status.contains(query, ignoreCase = true)
                            }
                            adapter.submitList(filteredPackages)
                        }
                    }
                })

                // Initially disable assign button
                binding.assignButton.isEnabled = false

                // Handle assign button
                binding.assignButton.setOnClickListener {
                    val selectedPackage = adapter.getSelectedPackage()
                    if (selectedPackage != null) {
                        dialog.dismiss()
                        showBulkAssignConfirmationDialog(selectedPackage.id, selectedPackage.name)
                    }
                }

                // Handle unassign button
                binding.unassignButton.setOnClickListener {
                    dialog.dismiss()
                    showBulkUnassignConfirmationDialog()
                }

                // Handle cancel button
                binding.cancelButton.setOnClickListener {
                    dialog.dismiss()
                }

                dialog.show()

            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error loading packages: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun showBulkAssignConfirmationDialog(packageId: Long, packageName: String) {
        val currentProducts = productsAdapter.currentList.size
        
        AlertDialog.Builder(requireContext())
            .setTitle("Confirm Bulk Assignment")
            .setMessage("Assign all $currentProducts scanned products to package '$packageName'?")
            .setPositiveButton("Assign") { _, _ ->
                performBulkAssignment(packageId, packageName)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun showBulkUnassignConfirmationDialog() {
        val currentProducts = productsAdapter.currentList.size

        AlertDialog.Builder(requireContext())
            .setTitle("Confirm Bulk Unassignment")
            .setMessage("Remove all $currentProducts scanned products from their current packages?")
            .setPositiveButton("Unassign") { _, _ ->
                performBulkUnassignment()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun performBulkAssignment(packageId: Long, packageName: String) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val productsToAssign = productsAdapter.currentList
                var successCount = 0
                var errorCount = 0
                
                for (product in productsToAssign) {
                    try {
                        viewModel.assignProductToPackage(product.id, packageId)
                        successCount++
                    } catch (e: Exception) {
                        errorCount++
                        // Continue with other products
                    }
                }
                
                val message = "Assigned $successCount products to '$packageName'"
                if (errorCount > 0) {
                    message.plus(" ($errorCount errors)")
                }
                
                Toast.makeText(requireContext(), message, Toast.LENGTH_LONG).show()
                
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error during bulk assignment: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun performBulkUnassignment() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val productsToUnassign = productsAdapter.currentList
                var successCount = 0
                var errorCount = 0

                for (product in productsToUnassign) {
                    try {
                        viewModel.unassignProductFromPackage(product.id)
                        successCount++
                    } catch (e: Exception) {
                        errorCount++
                        // Continue with other products
                    }
                }

                val message = "Unassigned $successCount products from packages"
                if (errorCount > 0) {
                    message.plus(" ($errorCount errors)")
                }

                Toast.makeText(requireContext(), message, Toast.LENGTH_LONG).show()

            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error during bulk unassignment: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun showMissingProductsDialog() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Get missing products with package info
                val missingProducts = viewModel.getMissingProducts()

                if (missingProducts.isEmpty()) {
                    Toast.makeText(requireContext(), "All products have been scanned", Toast.LENGTH_SHORT).show()
                    return@launch
                }

                // Create dialog
                val dialog = Dialog(requireContext())
                dialog.setTitle("Missing Products (${missingProducts.size})")

                // Create main container
                val mainContainer = LinearLayout(requireContext()).apply {
                    orientation = LinearLayout.VERTICAL
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    )
                }

                // Search input
                val searchInputLayout = com.google.android.material.textfield.TextInputLayout(requireContext()).apply {
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        setMargins(24, 16, 24, 8)
                    }
                    hint = "Search products..."
                    setBoxBackgroundMode(com.google.android.material.textfield.TextInputLayout.BOX_BACKGROUND_OUTLINE)
                }

                val searchEditText = com.google.android.material.textfield.TextInputEditText(searchInputLayout.context).apply {
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                }

                searchInputLayout.addView(searchEditText)
                mainContainer.addView(searchInputLayout)

                // Filter checkboxes
                val filterContainer = LinearLayout(requireContext()).apply {
                    orientation = LinearLayout.VERTICAL
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        setMargins(24, 8, 24, 16)
                    }
                }

                val showAssignedCheckbox = android.widget.CheckBox(requireContext()).apply {
                    text = "Show products assigned to packages"
                    isChecked = true
                    setTextColor(ContextCompat.getColor(requireContext(), com.example.inventoryapp.R.color.text_primary))
                }

                val showUnassignedCheckbox = android.widget.CheckBox(requireContext()).apply {
                    text = "Show products not assigned to packages"
                    isChecked = true
                    setTextColor(ContextCompat.getColor(requireContext(), com.example.inventoryapp.R.color.text_primary))
                }

                filterContainer.addView(showAssignedCheckbox)
                filterContainer.addView(showUnassignedCheckbox)
                mainContainer.addView(filterContainer)

                // RecyclerView
                val recyclerView = androidx.recyclerview.widget.RecyclerView(requireContext()).apply {
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        400 // Fixed height for dialog
                    ).apply {
                        setMargins(24, 0, 24, 16)
                    }
                    layoutManager = LinearLayoutManager(requireContext())
                }

                // Setup adapter
                val adapter = MissingProductsAdapter()
                recyclerView.adapter = adapter

                // Function to filter and display products
                fun updateDisplayedProducts() {
                    val searchQuery = searchEditText.text.toString().trim().toLowerCase()
                    val showAssigned = showAssignedCheckbox.isChecked
                    val showUnassigned = showUnassignedCheckbox.isChecked

                    val filteredProducts = missingProducts.filter { productWithPackage ->
                        // Search filter
                        val matchesSearch = searchQuery.isEmpty() ||
                                productWithPackage.product.name.toLowerCase().contains(searchQuery) ||
                                (productWithPackage.product.serialNumber?.toLowerCase()?.contains(searchQuery) == true) ||
                                (productWithPackage.packageInfo?.name?.toLowerCase()?.contains(searchQuery) == true)

                        // Package assignment filter
                        val isAssigned = productWithPackage.packageInfo != null
                        val matchesFilter = (showAssigned && isAssigned) || (showUnassigned && !isAssigned)

                        matchesSearch && matchesFilter
                    }

                    adapter.submitList(filteredProducts)
                }

                // Initial display
                updateDisplayedProducts()

                // Search listener
                searchEditText.addTextChangedListener(object : android.text.TextWatcher {
                    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                    override fun afterTextChanged(s: android.text.Editable?) {
                        updateDisplayedProducts()
                    }
                })

                // Filter listeners
                showAssignedCheckbox.setOnCheckedChangeListener { _, _ -> updateDisplayedProducts() }
                showUnassignedCheckbox.setOnCheckedChangeListener { _, _ -> updateDisplayedProducts() }

                mainContainer.addView(recyclerView)

                // Close button
                val closeButton = android.widget.Button(requireContext()).apply {
                    text = "Close"
                    setOnClickListener { dialog.dismiss() }
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        setMargins(24, 16, 24, 24)
                    }
                }
                mainContainer.addView(closeButton)

                dialog.setContentView(mainContainer)
                dialog.show()

            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Error loading missing products: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
