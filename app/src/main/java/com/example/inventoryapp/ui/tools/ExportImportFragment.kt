package com.example.inventoryapp.ui.tools

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RadioGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.R
import com.example.inventoryapp.databinding.FragmentExportImportBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.data.local.entity.ImportPreview
import com.example.inventoryapp.data.local.entity.ImportPreviewFilter
import com.example.inventoryapp.data.local.entities.PrinterEntity
import com.example.inventoryapp.utils.QRCodeGenerator
import com.example.inventoryapp.utils.BluetoothPrinterHelper
import com.example.inventoryapp.utils.PrinterSelectionHelper
import com.example.inventoryapp.utils.AppLogger
import com.example.inventoryapp.utils.FileHelper
import com.example.inventoryapp.printer.ZebraPrinterManager
import com.example.inventoryapp.printer.ZplContentGenerator
import com.example.inventoryapp.utils.DeviceInfo
import com.example.inventoryapp.utils.DeviceType
import com.example.inventoryapp.utils.ConnectionType
import com.google.gson.GsonBuilder
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import java.net.NetworkInterface

class ExportImportFragment : Fragment() {

    private var _binding: FragmentExportImportBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ExportImportViewModel
    private var connectedPrinter: BluetoothSocket? = null
    private lateinit var zebraPrinterManager: ZebraPrinterManager
    
    // Repositories for direct access
    private lateinit var productRepository: ProductRepository
    private lateinit var packageRepository: PackageRepository
    private lateinit var templateRepository: ProductTemplateRepository
    
    // Multi-QR state
    private var currentMultiQrBitmaps: List<Bitmap> = emptyList()
    private var currentMultiQrIndex: Int = 0
    
    companion object {
        private const val PREFS_NAME = "printer_preferences"
        private const val KEY_PRINTER_MAC = "printer_mac_address"
    }

    private val createFileLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            result.data?.data?.let { uri ->
                viewLifecycleOwner.lifecycleScope.launch {
                    val file = File(requireContext().cacheDir, getExportFileName("json"))
                    val success = viewModel.exportToJson(file)
                    if (success) {
                        requireContext().contentResolver.openOutputStream(uri)?.use { output ->
                            file.inputStream().use { input ->
                                input.copyTo(output)
                            }
                        }
                        file.delete()
                    }
                }
            }
        }
    }

    private val openFileLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            result.data?.data?.let { uri ->
                viewLifecycleOwner.lifecycleScope.launch {
                    val file = File(requireContext().cacheDir, "import_temp.json")
                    requireContext().contentResolver.openInputStream(uri)?.use { input ->
                        file.outputStream().use { output ->
                            input.copyTo(output)
                        }
                    }
                    // Show preview dialog before importing
                    showImportPreviewDialog(file)
                }
            }
        }
    }

    // Bluetooth permission launcher for Android 12+ (API 31+)
    private val bluetoothPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val allGranted = permissions.all { it.value }
        android.util.Log.d("ExportImport", "Permission results: $permissions, all granted: $allGranted")

        if (allGranted) {
            android.util.Log.d("ExportImport", "Bluetooth permissions granted, proceeding with print")
            // OLD: proceedWithZebraPrinting()
            Toast.makeText(requireContext(), "Old printer method removed - use printer selection", Toast.LENGTH_SHORT).show()
        } else {
            val deniedPermissions = permissions.filter { !it.value }.keys
            Toast.makeText(
                requireContext(),
                "Bluetooth permissions are required for printing to Bluetooth printer. Denied: $deniedPermissions",
                Toast.LENGTH_LONG
            ).show()
            android.util.Log.w("ExportImport", "Bluetooth permissions denied: $deniedPermissions")
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentExportImportBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupViewModel()
        setupButtons()
        observeStatus()
    }

    private fun setupViewModel() {
        val database = AppDatabase.getDatabase(requireContext())
        productRepository = ProductRepository(database.productDao())
        packageRepository = PackageRepository(database.packageDao(), database.productDao())
        templateRepository = ProductTemplateRepository(database.productTemplateDao())
        val backupRepository = com.example.inventoryapp.data.repository.ImportBackupRepository(database.importBackupDao())
        
        // Initialize Zebra printer manager
        zebraPrinterManager = ZebraPrinterManager(requireContext())
        
        viewModel = ExportImportViewModel(
            productRepository,
            packageRepository,
            templateRepository,
            backupRepository
        )
    }

    private fun setupButtons() {
        binding.exportButton.setOnClickListener {
            showExportOptions()
        }

        binding.importButton.setOnClickListener {
            importData()
        }

        binding.undoImportButton.setOnClickListener {
            showUndoConfirmationDialog()
        }

        binding.shareQrButton.setOnClickListener {
            shareViaQR()
        }

        binding.scanQrButton.setOnClickListener {
            scanQRToImport()
        }

        binding.printQrCodeButton.setOnClickListener {
            printQRCodeWithPrinterSelection()
        }
        
        binding.previousQrButton.setOnClickListener {
            navigateMultiQr(-1)
        }
        
        binding.nextQrButton.setOnClickListener {
            navigateMultiQr(1)
        }
        
        binding.printAllQrButton.setOnClickListener {
            showPrintAllMultiQrDialog()
        }
    }

    private fun observeStatus() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.status.collect { status ->
                binding.statusText.text = status
            }
        }
        
        // Observe backup availability to enable/disable Undo button
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.hasRecentBackup.collect { hasBackup ->
                binding.undoImportButton.isEnabled = hasBackup
                binding.undoImportButton.alpha = if (hasBackup) 1.0f else 0.5f
            }
        }
    }

    private fun showExportOptions() {
        AlertDialog.Builder(requireContext())
            .setTitle("Export Format")
            .setMessage("Choose export format")
            .setPositiveButton("JSON") { _, _ ->
                exportDataAsJson()
            }
            .setNegativeButton("CSV") { _, _ ->
                exportDataAsCsv()
            }
            .setNeutralButton("Cancel", null)
            .show()
    }

    private fun exportDataAsJson() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                AppLogger.logAction("Export JSON Initiated")
                val exportsDir = FileHelper.getExportsDirectory()
                val file = File(exportsDir, getExportFileName("json"))
                
                val success = viewModel.exportToJson(file)
                if (success) {
                    Toast.makeText(
                        requireContext(),
                        "Exported to: Documents/inventory/exports/",
                        Toast.LENGTH_LONG
                    ).show()
                }
            } catch (e: Exception) {
                AppLogger.logError("Export JSON", e)
                Toast.makeText(
                    requireContext(),
                    "Export failed: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun exportDataAsCsv() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                AppLogger.logAction("Export CSV Initiated")
                val exportsDir = FileHelper.getExportsDirectory()
                val file = File(exportsDir, getExportFileName("csv"))
                
                val success = viewModel.exportToCsv(file)
                if (success) {
                    Toast.makeText(
                        requireContext(),
                        "Exported to: Documents/inventory/exports/",
                        Toast.LENGTH_LONG
                    ).show()
                }
            } catch (e: Exception) {
                AppLogger.logError("Export CSV", e)
                Toast.makeText(
                    requireContext(),
                    "Export failed: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun importData() {
        viewLifecycleOwner.lifecycleScope.launch {
            AppLogger.logAction("Import Initiated")
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
        }
        openFileLauncher.launch(intent)
    }

    private fun showUndoConfirmationDialog() {
        AlertDialog.Builder(requireContext())
            .setTitle(R.string.undo_last_import)
            .setMessage(R.string.confirm_undo_import)
            .setIcon(android.R.drawable.ic_dialog_alert)
            .setPositiveButton(R.string.ok) { _, _ ->
                performUndoImport()
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }

    private fun performUndoImport() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                AppLogger.logAction("Undo Import", "Started")
                
                Toast.makeText(
                    requireContext(),
                    "Restoring from backup...",
                    Toast.LENGTH_SHORT
                ).show()
                
                val success = viewModel.undoLastImport()
                
                if (success) {
                    Toast.makeText(
                        requireContext(),
                        R.string.undo_import_success,
                        Toast.LENGTH_LONG
                    ).show()
                    AppLogger.logAction("Undo Import", "Success")
                } else {
                    Toast.makeText(
                        requireContext(),
                        R.string.undo_import_failed,
                        Toast.LENGTH_LONG
                    ).show()
                    AppLogger.logAction("Undo Import", "Failed")
                }
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "${getString(R.string.undo_import_failed)}: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
                AppLogger.logError("Undo Import", e)
            }
        }
    }

    private fun shareViaQR() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                AppLogger.logAction("QR Code Share Initiated")
                
                // Clear previous multi-QR state
                clearMultiQrState()
                
                val file = File(requireContext().cacheDir, getExportFileName("json"))
                val success = viewModel.exportToJson(file)
                
                if (success) {
                    val jsonContent = file.readText()
                    
                    AppLogger.d("QR Share", "Data size: ${jsonContent.length} chars")
                    
                    // Generate QR with automatic compression
                    val qrBitmap = QRCodeGenerator.generateQRCode(jsonContent, 800, 800)
                    
                    if (qrBitmap != null) {
                        binding.qrCodeImage.setImageBitmap(qrBitmap)
                        binding.qrCodeImage.visibility = View.VISIBLE
                        AppLogger.logAction("QR Code Generated Successfully (with compression if needed)")
                        
                        val sizeInfo = if (jsonContent.length > 2000) {
                            "Large dataset - compressed for QR"
                        } else {
                            "QR Code ready to scan"
                        }
                        
                        Toast.makeText(requireContext(), sizeInfo, Toast.LENGTH_LONG).show()
                    } else {
                        // If single QR fails, try multi-part
                        showMultiPartQROption(jsonContent)
                    }
                }
                file.delete()
            } catch (e: Exception) {
                AppLogger.logError("QR Share", e)
                Toast.makeText(requireContext(), "Error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    private fun showMultiPartQROption(jsonContent: String) {
        AlertDialog.Builder(requireContext())
            .setTitle("Large Database")
            .setMessage("Database is very large. Options:\n\n1. Generate multiple QR codes (for printing)\n2. Use file export instead\n3. Export individual packages")
            .setPositiveButton("Multi-Part QR") { _, _ ->
                generateMultiPartQR(jsonContent)
            }
            .setNegativeButton("File Export") { _, _ ->
                exportDataAsJson()
            }
            .setNeutralButton("Cancel", null)
            .show()
    }
    
    private fun generateMultiPartQR(jsonContent: String) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val qrBitmaps = QRCodeGenerator.generateMultiPartQRCodes(jsonContent, 800, 800)
                
                if (qrBitmaps.isNotEmpty()) {
                    AppLogger.logAction("Generated ${qrBitmaps.size} multi-part QR codes")
                    
                    // Store multi-QR state
                    currentMultiQrBitmaps = qrBitmaps
                    currentMultiQrIndex = 0
                    
                    // Show first QR
                    displayMultiQr(0)
                    
                    // Show navigation controls
                    binding.multiQrNavigationLayout.visibility = View.VISIBLE
                    binding.printAllQrButton.visibility = View.VISIBLE
                    updateMultiQrNavigation()
                    
                    Toast.makeText(
                        requireContext(), 
                        "Generated ${qrBitmaps.size} QR codes. Use arrows to navigate.",
                        Toast.LENGTH_LONG
                    ).show()
                } else {
                    Toast.makeText(requireContext(), "Failed to generate QR codes. Use file export.", Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                AppLogger.logError("Multi-Part QR", e)
                Toast.makeText(requireContext(), "Error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    private fun displayMultiQr(index: Int) {
        if (index in currentMultiQrBitmaps.indices) {
            binding.qrCodeImage.setImageBitmap(currentMultiQrBitmaps[index])
            binding.qrCodeImage.visibility = View.VISIBLE
            currentMultiQrIndex = index
            updateMultiQrNavigation()
        }
    }
    
    private fun navigateMultiQr(direction: Int) {
        val newIndex = currentMultiQrIndex + direction
        if (newIndex in currentMultiQrBitmaps.indices) {
            displayMultiQr(newIndex)
        }
    }
    
    private fun updateMultiQrNavigation() {
        if (currentMultiQrBitmaps.isEmpty()) return
        
        binding.qrCounterText.text = "${currentMultiQrIndex + 1}/${currentMultiQrBitmaps.size}"
        binding.previousQrButton.isEnabled = currentMultiQrIndex > 0
        binding.nextQrButton.isEnabled = currentMultiQrIndex < currentMultiQrBitmaps.size - 1
    }
    
    private fun showPrintAllMultiQrDialog() {
        if (currentMultiQrBitmaps.isEmpty()) return
        
        AlertDialog.Builder(requireContext())
            .setTitle("Print All QR Codes?")
            .setMessage("This will print all ${currentMultiQrBitmaps.size} QR code parts.\n\n" +
                    "Make sure printer is ready and has enough labels.\n\n" +
                    "Continue?")
            .setPositiveButton("Print All") { _, _ ->
                printMultiPartQRCodesWithPrinterSelection(currentMultiQrBitmaps)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
    
    private fun showPrintAllPartsOption(@Suppress("UNUSED_PARAMETER") qrBitmaps: List<Bitmap>) {
        // REMOVED - now using showPrintAllMultiQrDialog
    }
    
    private fun printMultiPartQRCodesWithPrinterSelection(qrBitmaps: List<Bitmap>) {
        PrinterSelectionHelper.getDefaultOrSelectPrinter(this) { selectedPrinter ->
            printMultiPartQRCodes(qrBitmaps, selectedPrinter)
        }
    }
    
    private fun printMultiPartQRCodes(qrBitmaps: List<Bitmap>, printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                binding.printerStatusText.text = "Connecting to ${printer.name}..."
                
                val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), printer.macAddress)
                if (socket != null) {
                    var successCount = 0
                    qrBitmaps.forEachIndexed { index, bitmap ->
                        binding.printerStatusText.text = "Printing ${index + 1}/${qrBitmaps.size}..."
                        
                        val header = "Database Export - Part ${index + 1}/${qrBitmaps.size}"
                        val footer = "Scan all parts in order"
                        val success = BluetoothPrinterHelper.printQRCode(socket, bitmap, header, footer)
                        if (success) successCount++
                        
                        // Small delay between prints
                        if (index < qrBitmaps.size - 1) {
                            kotlinx.coroutines.delay(500)
                        }
                    }
                    socket.close()
                    
                    binding.printerStatusText.text = "✅ Printed $successCount/${qrBitmaps.size} QR codes"
                    Toast.makeText(
                        requireContext(), 
                        "✅ Successfully printed $successCount/${qrBitmaps.size} QR codes to ${printer.name}",
                        Toast.LENGTH_LONG
                    ).show()
                } else {
                    binding.printerStatusText.text = "❌ Failed to connect to ${printer.name}"
                    Toast.makeText(requireContext(), "❌ Failed to connect to printer", Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                AppLogger.logError("Multi-Part Print", e)
                binding.printerStatusText.text = "❌ Print error"
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun scanQRToImport() {
        // Navigate to import preview instead of scanner
        findNavController().navigate(R.id.action_export_import_to_import_preview)
    }
    
    private fun savePrinterMacAddress(macAddress: String) {
        requireContext().getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_PRINTER_MAC, macAddress)
            .apply()
    }
    
    
    private fun requestBluetoothPermissionsAndPrint() {
        android.util.Log.d("ExportImport", "Device SDK: ${Build.VERSION.SDK_INT}, Android 12+ check: ${Build.VERSION.SDK_INT >= 31}")

        if (Build.VERSION.SDK_INT >= 31) {
            // Android 12+ (API 31+): BLUETOOTH_SCAN and BLUETOOTH_CONNECT are runtime permissions
            val permissions = arrayOf(
                "android.permission.BLUETOOTH_SCAN",
                "android.permission.BLUETOOTH_CONNECT"
            )

            val missingPermissions = permissions.filter {
                val granted = ContextCompat.checkSelfPermission(requireContext(), it) == PackageManager.PERMISSION_GRANTED
                val shouldShowRationale = shouldShowRequestPermissionRationale(it)
                android.util.Log.d("ExportImport", "Permission $it granted: $granted, shouldShowRationale: $shouldShowRationale")
                !granted
            }

            // Check if any permissions are permanently denied
            val permanentlyDenied = missingPermissions.filter { !shouldShowRequestPermissionRationale(it) }
            if (permanentlyDenied.isNotEmpty() && missingPermissions.isNotEmpty()) {
                android.util.Log.w("ExportImport", "Permissions permanently denied: $permanentlyDenied")
                // Show dialog to open app settings
                showPermissionSettingsDialog()
                return
            }

            android.util.Log.d("ExportImport", "Missing permissions: ${missingPermissions.size}")

            if (missingPermissions.isNotEmpty()) {
                android.util.Log.d("ExportImport", "Requesting Bluetooth runtime permissions for Android 12+")
                try {
                    bluetoothPermissionLauncher.launch(missingPermissions.toTypedArray())
                    android.util.Log.d("ExportImport", "Permission launcher launched successfully")
                } catch (e: Exception) {
                    android.util.Log.e("ExportImport", "Error launching permission request", e)
                    Toast.makeText(requireContext(), "Error requesting permissions: ${e.message}", Toast.LENGTH_SHORT).show()
                }
                return
            } else {
                android.util.Log.d("ExportImport", "All Bluetooth permissions already granted")
            }
        } else {
            // For SDK < 31: Bluetooth permissions are normal permissions, auto-granted at install
            android.util.Log.d("ExportImport", "Bluetooth permissions auto-granted for Android < 12")
        }

        // OLD: proceedWithZebraPrinting()
        Toast.makeText(requireContext(), "Old printer method removed - use printer selection", Toast.LENGTH_SHORT).show()
    }
    
    private fun showPermissionSettingsDialog() {
        AlertDialog.Builder(requireContext())
            .setTitle("Bluetooth Permissions Required")
            .setMessage("Bluetooth permissions are required to connect to the Zebra printer. Please enable them in app settings.")
            .setPositiveButton("Open Settings") { _, _ ->
                try {
                    val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = android.net.Uri.fromParts("package", requireContext().packageName, null)
                    }
                    startActivity(intent)
                } catch (e: Exception) {
                    Toast.makeText(requireContext(), "Cannot open settings: ${e.message}", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
    
    /* OLD PRINTER CODE - COMMENTED OUT
    private fun proceedWithZebraPrinting() {
        val macAddress = binding.printerMacEditText.text.toString().trim()

        // Show loading
        binding.printerStatusText.text = "Exporting data and connecting to Zebra printer..."
        binding.printZebraButton.isEnabled = false

        // Export data to JSON and print QR code
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Export data to temporary JSON file
                val tempFile = File(requireContext().cacheDir, "zebra_export_temp.json")
                val exportSuccess = viewModel.exportToJson(tempFile)

                if (!exportSuccess) {
                    requireActivity().runOnUiThread {
                        binding.printZebraButton.isEnabled = true
                        binding.printerStatusText.text = "Export failed"
                        Toast.makeText(requireContext(), "Failed to export data", Toast.LENGTH_SHORT).show()
                    }
                    return@launch
                }

                // Read exported JSON data
                val jsonData = tempFile.readText()
                tempFile.delete() // Clean up temp file

                // Compress data if needed (automatic based on size)
                val qrData = if (jsonData.length > 2000) {
                    // Use compression for large data
                    QRCodeGenerator.compressAndEncode(jsonData)
                } else {
                    // Use raw JSON for small data
                    jsonData
                }
                
                AppLogger.d("ZebraPrint", "Original data: ${jsonData.length} chars, QR data: ${qrData.length} chars")

                // Generate QR code label with compressed data
                val zplContent = ZplContentGenerator.generateQRCodeLabel(qrData)
                val error = zebraPrinterManager.printDocument(macAddress, zplContent)

                requireActivity().runOnUiThread {
                    binding.printZebraButton.isEnabled = true
                    if (error == null) {
                        binding.printerStatusText.text = "QR code printed successfully!"
                        Toast.makeText(requireContext(), "QR code with inventory data sent to printer", Toast.LENGTH_SHORT).show()
                    } else {
                        binding.printerStatusText.text = "Print failed: $error"
                        Toast.makeText(requireContext(), "Print failed: $error", Toast.LENGTH_SHORT).show()
                    }
                }
            } catch (e: Exception) {
                requireActivity().runOnUiThread {
                    binding.printZebraButton.isEnabled = true
                    binding.printerStatusText.text = "Print error: ${e.message}"
                    Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    END OLD PRINTER CODE */

    /* OLD PRINTER CODE - COMMENTED OUT  
    private fun proceedWithPrinting() {
        val macAddress = binding.printerMacEditText.text.toString().trim()
        
        // Validate MAC address format
        if (macAddress.isEmpty()) {
            Toast.makeText(requireContext(), "Please enter printer MAC address", Toast.LENGTH_SHORT).show()
            return
        }
        
        // Basic MAC address validation (AA:BB:CC:DD:EE:FF format)
        val macPattern = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$".toRegex()
        if (!macPattern.matches(macAddress)) {
            Toast.makeText(requireContext(), "Invalid MAC address format. Use: AA:BB:CC:DD:EE:FF", Toast.LENGTH_LONG).show()
            return
        }
        
        // Check Bluetooth availability
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        if (bluetoothAdapter == null) {
            Toast.makeText(requireContext(), "Bluetooth not available on this device", Toast.LENGTH_SHORT).show()
            return
        }
        
        if (!bluetoothAdapter.isEnabled) {
            Toast.makeText(requireContext(), "Please enable Bluetooth first", Toast.LENGTH_LONG).show()
            try {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                startActivity(enableBtIntent)
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Enable Bluetooth manually in Settings", Toast.LENGTH_LONG).show()
            }
            return
        }
        
        // Print QR code to entered MAC address
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                binding.printerStatusText.text = "Connecting to printer...\nMAC: $macAddress"
                
                // Save MAC address for future use
                savePrinterMacAddress(macAddress)
                
                // Generate QR with full database export
                val products = productRepository.getAllProducts().first()
                val packages = packageRepository.getAllPackages().first()
                val templates = templateRepository.getAllTemplates().first()
                
                val exportData = ExportData(
                    products = products,
                    packages = packages,
                    templates = templates
                )
                
                val gson = GsonBuilder().create()
                val jsonContent = gson.toJson(exportData)
                
                val qrBitmap = QRCodeGenerator.generateQRCode(jsonContent, 384, 384)
                if (qrBitmap != null) {
                    // Connect and print
                    android.util.Log.d("ExportImport", "Printing to MAC: $macAddress")
                    val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), macAddress)
                    if (socket != null) {
                        val success = BluetoothPrinterHelper.printQRCode(
                            socket, 
                            qrBitmap,
                            "INVENTORY DATABASE",
                            "${products.size}P ${packages.size}Pk ${templates.size}T"
                        )
                        socket.close()
                        
                        if (success) {
                            binding.printerStatusText.text = "✅ Print sent to:\n$macAddress"
                            Toast.makeText(requireContext(), "✅ QR code printed successfully!", Toast.LENGTH_SHORT).show()
                        } else {
                            binding.printerStatusText.text = "❌ Print failed"
                            Toast.makeText(requireContext(), "❌ Print failed - check printer", Toast.LENGTH_SHORT).show()
                        }
                    } else {
                        binding.printerStatusText.text = "❌ Failed to connect\nMAC: $macAddress"
                        Toast.makeText(requireContext(), "❌ Connection failed. Check:\n1. Bluetooth ON\n2. Printer ON\n3. MAC address correct\n4. Printer in range", Toast.LENGTH_LONG).show()
                    }
                    qrBitmap.recycle()
                } else {
                    binding.printerStatusText.text = "❌ QR generation failed"
                    Toast.makeText(requireContext(), "Failed to generate QR code", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                binding.printerStatusText.text = "❌ Error: ${e.message}"
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_LONG).show()
                android.util.Log.e("ExportImport", "Print error", e)
            }
        }
    }
    END OLD PRINTER CODE */
    
    private fun printQRCodeWithPrinterSelection() {
        PrinterSelectionHelper.getDefaultOrSelectPrinter(this) { selectedPrinter ->
            printQRCodeWithPrinter(selectedPrinter)
        }
    }
    
    private fun printQRCodeWithPrinter(printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                binding.printerStatusText.text = "Generating QR code..."
                
                // Generate QR with full database export
                val products = productRepository.getAllProducts().first()
                val packages = packageRepository.getAllPackages().first()
                val templates = templateRepository.getAllTemplates().first()
                
                val exportData = ExportData(
                    products = products,
                    packages = packages,
                    templates = templates
                )
                
                val gson = GsonBuilder().create()
                val jsonContent = gson.toJson(exportData)
                
                AppLogger.d("QRPrint", "Data size: ${jsonContent.length} chars")
                
                // Try to generate single QR code (QRCodeGenerator handles compression internally)
                val qrBitmap = QRCodeGenerator.generateQRCode(jsonContent, 384, 384)
                
                if (qrBitmap != null) {
                    // Single QR succeeded - print it
                    binding.printerStatusText.text = "Connecting to ${printer.name}..."
                    
                    val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), printer.macAddress)
                    if (socket != null) {
                        binding.printerStatusText.text = "Printing..."
                        
                        val header = "INVENTORY DATABASE"
                        val footer = "${products.size}P ${packages.size}Pk ${templates.size}T"
                        val success = BluetoothPrinterHelper.printQRCode(socket, qrBitmap, header, footer)
                        
                        socket.close()
                        
                        if (success) {
                            binding.printerStatusText.text = "✅ Printed successfully"
                            Toast.makeText(requireContext(), "✅ Print sent to ${printer.name}", Toast.LENGTH_SHORT).show()
                        } else {
                            binding.printerStatusText.text = "❌ Print failed"
                            Toast.makeText(requireContext(), "❌ Print failed - check printer", Toast.LENGTH_SHORT).show()
                        }
                    } else {
                        binding.printerStatusText.text = "❌ Connection failed"
                        Toast.makeText(requireContext(), "❌ Failed to connect to ${printer.name}", Toast.LENGTH_LONG).show()
                    }
                    qrBitmap.recycle()
                } else {
                    // Single QR failed - offer multi-part
                    binding.printerStatusText.text = "Database too large for single QR"
                    showMultiPartPrintDialog(jsonContent, printer)
                }
            } catch (e: Exception) {
                binding.printerStatusText.text = "❌ Error: ${e.message}"
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_SHORT).show()
                AppLogger.e("QRPrint", "Print error", e)
            }
        }
    }
    
    private fun showMultiPartPrintDialog(jsonContent: String, printer: PrinterEntity) {
        AlertDialog.Builder(requireContext())
            .setTitle("Large Database Detected")
            .setMessage("Database is too large for a single QR code.\n\n" +
                    "Would you like to print multiple QR codes?\n\n" +
                    "This will generate and print all parts automatically.")
            .setPositiveButton("Print Multi-Part") { _, _ ->
                printMultiPartDatabase(jsonContent, printer)
            }
            .setNegativeButton("Cancel") { _, _ ->
                binding.printerStatusText.text = ""
            }
            .show()
    }
    
    private fun printMultiPartDatabase(jsonContent: String, printer: PrinterEntity) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                binding.printerStatusText.text = "Generating multi-part QR codes..."
                
                val qrBitmaps = QRCodeGenerator.generateMultiPartQRCodes(jsonContent, 384, 384)
                
                if (qrBitmaps.isNotEmpty()) {
                    AppLogger.d("QRPrint", "Generated ${qrBitmaps.size} QR codes")
                    
                    // Confirm before printing all
                    requireActivity().runOnUiThread {
                        AlertDialog.Builder(requireContext())
                            .setTitle("Ready to Print")
                            .setMessage("Generated ${qrBitmaps.size} QR codes.\n\n" +
                                    "Print all codes to ${printer.name}?")
                            .setPositiveButton("Print All") { _, _ ->
                                printMultiPartQRCodes(qrBitmaps, printer)
                            }
                            .setNegativeButton("Cancel") { _, _ ->
                                binding.printerStatusText.text = ""
                            }
                            .show()
                    }
                } else {
                    binding.printerStatusText.text = "❌ Failed to generate QR codes"
                    Toast.makeText(requireContext(), "Failed to generate QR codes", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                binding.printerStatusText.text = "❌ Error: ${e.message}"
                Toast.makeText(requireContext(), "Error: ${e.message}", Toast.LENGTH_SHORT).show()
                AppLogger.e("QRPrint", "Multi-part generation error", e)
            }
        }
    }
    
    /* OLD PRINTER CODE - COMMENTED OUT
    private fun printQRCodeToEnteredMac() {
        // Check and request Bluetooth permissions (Android 12+ only)
        requestBluetoothPermissionsAndPrint()
    }
    
    private fun printTestQRCode() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // Check if we have a saved printer
                val savedMac = getSavedPrinterMacAddress()
                if (savedMac == null) {
                    Toast.makeText(requireContext(), "No printer configured. Please scan printer QR first.", Toast.LENGTH_LONG).show()
                    return@launch
                }
                
                // Generate QR with full database export
                val products = productRepository.getAllProducts().first()
                val packages = packageRepository.getAllPackages().first()
                val templates = templateRepository.getAllTemplates().first()
                
                val exportData = ExportData(
                    products = products,
                    packages = packages,
                    templates = templates
                )
                
                val gson = GsonBuilder().create()
                val jsonContent = gson.toJson(exportData)
                
                // Use automatic compression based on data size
                val qrData = if (jsonContent.length > 2000) {
                    QRCodeGenerator.compressAndEncode(jsonContent)
                } else {
                    jsonContent
                }
                AppLogger.d("TestQRPrint", "Original: ${jsonContent.length} chars, QR: ${qrData.length} chars")
                
                val qrBitmap = QRCodeGenerator.generateQRCode(qrData, 384, 384)
                if (qrBitmap != null) {
                    printDirectlyToSavedPrinter(
                        qrBitmap,
                        "INVENTORY DATABASE",
                        "${products.size}P ${packages.size}Pk ${templates.size}T"
                    )
                    qrBitmap.recycle()
                } else {
                    Toast.makeText(requireContext(), "Failed to generate QR code", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun startDeviceDiscovery() {
        if (!zebraPrinterManager.hasBluetoothPermissions()) {
            Toast.makeText(requireContext(), "Bluetooth permissions required. Please grant permission and try again.", Toast.LENGTH_LONG).show()
            // Request permissions
            requestBluetoothPermissionsAndPrint()
            return
        }

        if (!zebraPrinterManager.isBluetoothEnabled()) {
            Toast.makeText(requireContext(), "Please enable Bluetooth to discover devices", Toast.LENGTH_SHORT).show()
            return
        }

        val pairedDevices = zebraPrinterManager.getPairedDevices()
        binding.printerStatusText.text = "Found ${pairedDevices.size} paired Bluetooth devices"

        if (pairedDevices.isNotEmpty()) {
            showPairedDevicesDialog(pairedDevices)
        } else {
            Toast.makeText(requireContext(), "No paired Bluetooth devices found. Make sure your Zebra printer is paired.", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun showPairedDevicesDialog(devices: List<BluetoothDevice>) {
        val deviceNames = devices.map { "${it.name ?: "Unknown"} (${it.address})" }.toTypedArray()

        AlertDialog.Builder(requireContext())
            .setTitle("Select Bluetooth Device")
            .setItems(deviceNames) { _, which ->
                val selectedDevice = devices[which]
                binding.printerMacEditText.setText(selectedDevice.address)
                Toast.makeText(requireContext(), "Selected: ${selectedDevice.name}", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun detectCurrentSubnet(): String {
        return try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                val addresses = networkInterface.inetAddresses

                while (addresses.hasMoreElements()) {
                    val address = addresses.nextElement()
                    if (!address.isLoopbackAddress && address is java.net.Inet4Address) {
                        val hostAddress = address.hostAddress
                        // Extract subnet (first 3 octets)
                        val parts = hostAddress.split(".")
                        if (parts.size == 4) {
                            return "${parts[0]}.${parts[1]}.${parts[2]}"
                        }
                    }
                }
            }
            // Fallback to common subnet
            "192.168.1"
        } catch (e: Exception) {
            // Fallback to common subnet
            "192.168.1"
        }
    }



    private fun printOnZebraPrinter() {
        android.util.Log.d("ExportImport", "printOnZebraPrinter called, activity: ${activity != null}, isAdded: $isAdded")

        val isBluetoothSelected = binding.bluetoothRadioButton.isChecked

        if (isBluetoothSelected) {
            // Bluetooth connection
            val macAddress = binding.printerMacEditText.text.toString().trim()

            if (macAddress.isEmpty()) {
                Toast.makeText(requireContext(), "Please enter printer MAC address", Toast.LENGTH_SHORT).show()
                return
            }

            if (!isValidMacAddress(macAddress)) {
                Toast.makeText(requireContext(), "Invalid MAC address format", Toast.LENGTH_SHORT).show()
                return
            }

            // Check and request Bluetooth permissions before proceeding
            requestBluetoothPermissionsAndPrint()
        } else {
            // WiFi connection - not supported in simplified version
            Toast.makeText(requireContext(), "WiFi printing not supported in this version", Toast.LENGTH_SHORT).show()
        }
    }
    END OLD PRINTER CODE */



    private fun isValidMacAddress(mac: String): Boolean {
        val macPattern = Regex("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
        return macPattern.matches(mac)
    }

    private fun getExportFileName(extension: String): String {
        val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
        return "inventory_export_${dateFormat.format(Date())}.$extension"
    }

    /**
     * Show import preview dialog with filtering
     */
    private fun showImportPreviewDialog(importFile: File) {
        viewLifecycleOwner.lifecycleScope.launch {
            val preview = viewModel.generateImportPreview(importFile)
            
            if (preview == null) {
                Toast.makeText(requireContext(), "Failed to generate preview", Toast.LENGTH_SHORT).show()
                importFile.delete()
                return@launch
            }
            
            if (preview.isEmpty()) {
                Toast.makeText(requireContext(), "No new data to import", Toast.LENGTH_SHORT).show()
                importFile.delete()
                return@launch
            }
            
            // Create dialog
            val dialogView = layoutInflater.inflate(R.layout.dialog_import_preview, null)
            val dialog = AlertDialog.Builder(requireContext())
                .setView(dialogView)
                .setCancelable(false)
                .create()
            
            // Setup dialog components
            setupPreviewDialog(dialogView, preview, importFile, dialog)
            
            dialog.show()
        }
    }
    
    /**
     * Setup preview dialog with filtering and adapter
     */
    private fun setupPreviewDialog(
        dialogView: View,
        preview: ImportPreview,
        importFile: File,
        dialog: AlertDialog
    ) {
        val subtitle: android.widget.TextView = dialogView.findViewById(R.id.dialogSubtitle)
        val recyclerView: androidx.recyclerview.widget.RecyclerView = dialogView.findViewById(R.id.previewRecyclerView)
        val emptyState: android.widget.TextView = dialogView.findViewById(R.id.emptyStateText)
        val btnCancel: com.google.android.material.button.MaterialButton = dialogView.findViewById(R.id.btnCancel)
        val btnConfirm: com.google.android.material.button.MaterialButton = dialogView.findViewById(R.id.btnConfirmImport)
        
        // Chips for filtering
        val chipAll: com.google.android.material.chip.Chip = dialogView.findViewById(R.id.chipAll)
        val chipNewProducts: com.google.android.material.chip.Chip = dialogView.findViewById(R.id.chipNewProducts)
        val chipUpdateProducts: com.google.android.material.chip.Chip = dialogView.findViewById(R.id.chipUpdateProducts)
        val chipNewPackages: com.google.android.material.chip.Chip = dialogView.findViewById(R.id.chipNewPackages)
        val chipUpdatePackages: com.google.android.material.chip.Chip = dialogView.findViewById(R.id.chipUpdatePackages)
        val chipNewTemplates: com.google.android.material.chip.Chip = dialogView.findViewById(R.id.chipNewTemplates)
        
        // Set subtitle
        subtitle.text = getString(
            R.string.import_preview_subtitle,
            preview.totalNewItems,
            preview.totalUpdateItems
        )
        
        // Update chip labels with counts
        chipAll.text = getString(R.string.filter_all, preview.totalItems)
        chipNewProducts.text = getString(R.string.filter_new_products, preview.newProducts.size)
        chipUpdateProducts.text = getString(R.string.filter_update_products, preview.updateProducts.size)
        chipNewPackages.text = getString(R.string.filter_new_packages, preview.newPackages.size)
        chipUpdatePackages.text = getString(R.string.filter_update_packages, preview.updatePackages.size)
        chipNewTemplates.text = getString(R.string.filter_new_templates, preview.newTemplates.size)
        
        // Hide chips with 0 count
        chipNewProducts.visibility = if (preview.newProducts.isEmpty()) View.GONE else View.VISIBLE
        chipUpdateProducts.visibility = if (preview.updateProducts.isEmpty()) View.GONE else View.VISIBLE
        chipNewPackages.visibility = if (preview.newPackages.isEmpty()) View.GONE else View.VISIBLE
        chipUpdatePackages.visibility = if (preview.updatePackages.isEmpty()) View.GONE else View.VISIBLE
        chipNewTemplates.visibility = if (preview.newTemplates.isEmpty()) View.GONE else View.VISIBLE
        
        // Setup adapter
        val adapter = ImportPreviewAdapter()
        recyclerView.adapter = adapter
        
        // Function to update displayed items based on filter
        fun updateDisplayedItems(filter: ImportPreviewFilter) {
            val items = when (filter) {
                is ImportPreviewFilter.All -> {
                    preview.newProducts.map { ImportPreviewItem.ProductItem(it, true) } +
                    preview.updateProducts.map { ImportPreviewItem.ProductItem(it, false) } +
                    preview.newPackages.map { ImportPreviewItem.PackageItem(it, true) } +
                    preview.updatePackages.map { ImportPreviewItem.PackageItem(it, false) } +
                    preview.newTemplates.map { ImportPreviewItem.TemplateItem(it, true) }
                }
                is ImportPreviewFilter.NewProducts -> {
                    preview.newProducts.map { ImportPreviewItem.ProductItem(it, true) }
                }
                is ImportPreviewFilter.UpdateProducts -> {
                    preview.updateProducts.map { ImportPreviewItem.ProductItem(it, false) }
                }
                is ImportPreviewFilter.NewPackages -> {
                    preview.newPackages.map { ImportPreviewItem.PackageItem(it, true) }
                }
                is ImportPreviewFilter.UpdatePackages -> {
                    preview.updatePackages.map { ImportPreviewItem.PackageItem(it, false) }
                }
                is ImportPreviewFilter.NewTemplates -> {
                    preview.newTemplates.map { ImportPreviewItem.TemplateItem(it, true) }
                }
            }
            
            adapter.submitList(items)
            recyclerView.visibility = if (items.isEmpty()) View.GONE else View.VISIBLE
            emptyState.visibility = if (items.isEmpty()) View.VISIBLE else View.GONE
        }
        
        // Initial display - show all
        updateDisplayedItems(ImportPreviewFilter.All)
        
        // Setup chip listeners
        chipAll.setOnClickListener { updateDisplayedItems(ImportPreviewFilter.All) }
        chipNewProducts.setOnClickListener { updateDisplayedItems(ImportPreviewFilter.NewProducts) }
        chipUpdateProducts.setOnClickListener { updateDisplayedItems(ImportPreviewFilter.UpdateProducts) }
        chipNewPackages.setOnClickListener { updateDisplayedItems(ImportPreviewFilter.NewPackages) }
        chipUpdatePackages.setOnClickListener { updateDisplayedItems(ImportPreviewFilter.UpdatePackages) }
        chipNewTemplates.setOnClickListener { updateDisplayedItems(ImportPreviewFilter.NewTemplates) }
        
        // Cancel button
        btnCancel.setOnClickListener {
            importFile.delete()
            dialog.dismiss()
        }
        
        // Confirm import button
        btnConfirm.setOnClickListener {
            dialog.dismiss()
            viewLifecycleOwner.lifecycleScope.launch {
                val success = viewModel.importFromJson(importFile)
                importFile.delete()
                if (success) {
                    Toast.makeText(requireContext(), "Import successful", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(requireContext(), "Import failed", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    
    private fun clearMultiQrState() {
        // Recycle old bitmaps to free memory
        currentMultiQrBitmaps.forEach { it.recycle() }
        currentMultiQrBitmaps = emptyList()
        currentMultiQrIndex = 0
        
        // Hide navigation controls
        binding.multiQrNavigationLayout.visibility = View.GONE
        binding.printAllQrButton.visibility = View.GONE
    }

    override fun onDestroyView() {
        super.onDestroyView()
        clearMultiQrState()
        connectedPrinter?.let { BluetoothPrinterHelper.disconnect(it) }
        _binding = null
    }
}
