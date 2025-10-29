package com.example.inventoryapp.ui.templates

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
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

        // Check camera permission
        if (allPermissionsGranted()) {
            startCamera()
        } else {
            requestPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    private fun loadTemplateData() {
        viewLifecycleOwner.lifecycleScope.launch {
            templateRepository.getTemplateById(args.templateId).collect { template ->
                template?.let {
                    templateName = it.name
                    categoryId = it.categoryId
                    binding.statusText.text = "Scanning for: $templateName"
                }
            }
        }
    }

    private fun setupClickListeners() {
        binding.finishButton.setOnClickListener {
            finishScanning()
        }

        binding.cancelButton.setOnClickListener {
            findNavController().navigateUp()
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(requireContext())

        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

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
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    viewLifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalyzer
                )
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Failed to start camera: ${e.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }

        }, ContextCompat.getMainExecutor(requireContext()))
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
                binding.lastScannedText.text = "Ready to scan..."
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
        _binding = null
    }
}
