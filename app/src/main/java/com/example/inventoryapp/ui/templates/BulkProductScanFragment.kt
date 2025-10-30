package com.example.inventoryapp.ui.templates

import android.Manifest
import android.content.pm.PackageManager
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
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentBulkScanBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.ui.scanner.BarcodeAnalyzer
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class BulkProductScanFragment : Fragment() {

    private var _binding: FragmentBulkScanBinding? = null
    private val binding get() = _binding!!

    private val args: BulkProductScanFragmentArgs by navArgs()
    private lateinit var templateRepository: ProductTemplateRepository
    private lateinit var productRepository: ProductRepository
    private lateinit var cameraExecutor: ExecutorService

    private var templateName: String = ""
    private var categoryId: Long? = null
    private var scannedCount: Int = 0
    private val scannedSerials = mutableSetOf<String>()
    
    private var isCameraMode = false
    private var cameraProvider: ProcessCameraProvider? = null
    private var currentInputField: TextInputEditText? = null

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            startCamera()
        } else {
            Toast.makeText(
                requireContext(),
                getString(R.string.scanner_permission_required),
                Toast.LENGTH_LONG
            ).show()
            // Switch back to manual mode
            switchToManualMode()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        cameraExecutor = Executors.newSingleThreadExecutor()

        val database = AppDatabase.getDatabase(requireContext())
        templateRepository = ProductTemplateRepository(database.productTemplateDao())
        productRepository = ProductRepository(database.productDao())
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentBulkScanBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        loadTemplateData()
        setupClickListeners()
        updateUI()
        
        // Start in manual entry mode
        switchToManualMode()
        addProductInputField()
    }

    private fun loadTemplateData() {
        viewLifecycleOwner.lifecycleScope.launch {
            templateRepository.getTemplateById(args.templateId).collect { template ->
                template?.let {
                    templateName = it.name
                    categoryId = it.categoryId
                }
            }
        }
    }

    private fun setupClickListeners() {
        binding.toggleScanModeButton.setOnClickListener {
            if (isCameraMode) {
                switchToManualMode()
            } else {
                switchToCameraMode()
            }
        }
        
        binding.finishButton.setOnClickListener {
            finishScanning()
        }

        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
    }
    
    private fun switchToCameraMode() {
        isCameraMode = true
        
        // Show camera views
        binding.previewView.visibility = View.VISIBLE
        binding.scanOverlay.visibility = View.VISIBLE
        binding.statusText.visibility = View.VISIBLE
        
        // Hide manual entry
        binding.manualEntryContainer.visibility = View.GONE
        
        // Update button
        binding.toggleScanModeButton.text = "Manual Entry"
        binding.toggleScanModeButton.setIconResource(android.R.drawable.ic_menu_edit)
        
        // Start camera
        if (allPermissionsGranted()) {
            startCamera()
        } else {
            requestPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }
    
    private fun switchToManualMode() {
        isCameraMode = false
        
        // Hide camera views
        binding.previewView.visibility = View.GONE
        binding.scanOverlay.visibility = View.GONE
        binding.statusText.visibility = View.GONE
        
        // Show manual entry
        binding.manualEntryContainer.visibility = View.VISIBLE
        
        // Update button
        binding.toggleScanModeButton.text = "Scan with Camera"
        binding.toggleScanModeButton.setIconResource(android.R.drawable.ic_menu_camera)
        
        // Stop camera
        stopCamera()
    }
    
    private fun addProductInputField() {
        val context = requireContext()
        val productNumber = scannedCount + 1

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

        // Create TextInputLayout (takes most of the space)
        val inputLayout = TextInputLayout(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                0, // width = 0 for weight
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f // weight = 1 to take remaining space
            )
            hint = "$productNumber. Product"
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
                    if (serialNumber.isNotEmpty()) {
                        processManualEntry(serialNumber)
                    }
                    true
                } else {
                    false
                }
            }

            // Auto-focus for barcode scanners that act as keyboard
            addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                override fun afterTextChanged(s: Editable?) {
                    // If scanner inputs entire string at once, process it
                    val text = s.toString().trim()
                    if (text.isNotEmpty() && text.length >= 5) {
                        // Check if this looks like a barcode (no manual typing in progress)
                        // We'll process it after a short delay to allow scanner to finish
                        postDelayed({
                            if (this@apply.text.toString().trim() == text) {
                                processManualEntry(text)
                            }
                        }, 100)
                    }
                }
            })
        }

        // Create delete button (X)
        val deleteButton = androidx.appcompat.widget.AppCompatImageButton(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                resources.getDimensionPixelSize(com.google.android.material.R.dimen.design_fab_size_mini),
                resources.getDimensionPixelSize(com.google.android.material.R.dimen.design_fab_size_mini)
            ).apply {
                marginStart = 8
            }
            setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
            contentDescription = "Delete this entry"
            background = null
            setColorFilter(ContextCompat.getColor(context, android.R.color.holo_red_dark))
            setOnClickListener {
                removeProductInputField(horizontalContainer, editText)
            }
        }

        // Assemble the layout
        inputLayout.addView(editText)
        horizontalContainer.addView(inputLayout)
        horizontalContainer.addView(deleteButton)

        binding.productsInputContainer.addView(horizontalContainer)

        // Store current input field reference
        currentInputField = editText

        // Focus the new field
        editText.requestFocus()
    }

    private fun removeProductInputField(container: LinearLayout, editText: TextInputEditText) {
        // Get the serial number from the field
        val serialNumber = editText.text.toString().trim()

        // If this field was already processed (has serial number), remove from scanned list
        if (serialNumber.isNotEmpty() && scannedSerials.contains(serialNumber)) {
            scannedSerials.remove(serialNumber)
            scannedCount--

            // Remove the product from database if it was added
            viewLifecycleOwner.lifecycleScope.launch {
                try {
                    productRepository.deleteProductBySerialNumber(serialNumber)
                    showStatus("🗑️ Removed: $serialNumber")
                    updateUI()
                } catch (e: Exception) {
                    showStatus("❌ Error removing: ${e.message}")
                }
            }
        }

        // Remove the container from the layout
        binding.productsInputContainer.removeView(container)

        // If this was the current input field, clear the reference
        if (currentInputField == editText) {
            currentInputField = null
        }

        // If no more input fields, add a new empty one
        if (binding.productsInputContainer.childCount == 0) {
            addProductInputField()
        }
    }
    
    private fun processManualEntry(serialNumber: String) {
        if (serialNumber.isEmpty()) return

        // Check if already scanned
        if (scannedSerials.contains(serialNumber)) {
            showStatus("⚠️ Already scanned: $serialNumber")
            currentInputField?.setText("")
            return
        }

        // Add product with this serial number
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Check if serial number exists in database
                val exists = productRepository.isSerialNumberExists(serialNumber)
                if (exists) {
                    showStatus("❌ Duplicate SN: $serialNumber")
                    currentInputField?.setText("")
                    return@launch
                }

                // Create new product
                val product = ProductEntity(
                    name = templateName,
                    categoryId = categoryId,
                    serialNumber = serialNumber
                )

                productRepository.insertProduct(product)
                
                // Add to scanned list
                scannedSerials.add(serialNumber)
                scannedCount++

                // Update UI
                updateUI()
                showStatus("✅ Added: $serialNumber")
                
                // Clear current field and add new one
                currentInputField?.isEnabled = false
                addProductInputField()

            } catch (e: Exception) {
                showStatus("❌ Error: ${e.message}")
                currentInputField?.setText("")
            }
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(requireContext())

        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(binding.previewView.surfaceProvider)
                }

            val imageAnalyzer = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()
                .also {
                    it.setAnalyzer(cameraExecutor, BarcodeAnalyzer(
                        onBarcodeDetected = { value, format ->
                            processBarcode(value)
                        },
                        onError = { exception ->
                            showStatus("❌ Scan error: ${exception.message}")
                        }
                    ))
                }

            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

            try {
                cameraProvider?.unbindAll()
                cameraProvider?.bindToLifecycle(
                    viewLifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalyzer
                )
                binding.statusText.text = "Scanning for: $templateName"
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Failed to start camera: ${e.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }

        }, ContextCompat.getMainExecutor(requireContext()))
    }
    
    private fun stopCamera() {
        cameraProvider?.unbindAll()
        cameraProvider = null
    }

    private fun processBarcode(serialNumber: String) {
        if (serialNumber.isEmpty()) return

        // Check if already scanned
        if (scannedSerials.contains(serialNumber)) {
            showStatus("⚠️ Already scanned: $serialNumber")
            return
        }

        // Add product with this serial number
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Check if serial number exists in database
                val exists = productRepository.isSerialNumberExists(serialNumber)
                if (exists) {
                    showStatus("❌ Duplicate SN: $serialNumber")
                    return@launch
                }

                // Create new product
                val product = ProductEntity(
                    name = templateName,
                    categoryId = categoryId,
                    serialNumber = serialNumber
                )

                productRepository.insertProduct(product)
                
                // Add to scanned list
                scannedSerials.add(serialNumber)
                scannedCount++

                // Update UI
                updateUI()
                showStatus("✅ Added: $serialNumber")

            } catch (e: Exception) {
                showStatus("❌ Error: ${e.message}")
            }
        }
    }

    private fun showStatus(message: String) {
        activity?.runOnUiThread {
            binding.lastScannedText.text = message
            Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
        }
    }

    private fun updateUI() {
        activity?.runOnUiThread {
            binding.scanCountText.text = "Scanned: $scannedCount products"
            if (scannedCount == 0) {
                binding.lastScannedText.text = "Ready to add products..."
            }
        }
    }

    private fun finishScanning() {
        if (scannedCount > 0) {
            Toast.makeText(
                requireContext(),
                "Added $scannedCount products successfully!",
                Toast.LENGTH_LONG
            ).show()
        }
        findNavController().navigateUp()
    }

    private fun allPermissionsGranted() = ContextCompat.checkSelfPermission(
        requireContext(),
        Manifest.permission.CAMERA
    ) == PackageManager.PERMISSION_GRANTED

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        stopCamera()
        _binding = null
    }
}
