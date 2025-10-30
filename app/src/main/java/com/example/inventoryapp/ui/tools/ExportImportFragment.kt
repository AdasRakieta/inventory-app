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
import com.example.inventoryapp.utils.QRCodeGenerator
import com.example.inventoryapp.utils.BluetoothPrinterHelper
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
                    viewModel.importFromJson(file)
                    file.delete()
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
            proceedWithZebraPrinting()
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
        
        // Initialize Zebra printer manager
        zebraPrinterManager = ZebraPrinterManager(requireContext())
        
        viewModel = ExportImportViewModel(
            productRepository,
            packageRepository,
            templateRepository
        )
    }

    private fun setupButtons() {
        // Setup connection type radio group
        binding.connectionTypeRadioGroup.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                R.id.bluetoothRadioButton -> {
                    binding.bluetoothSection.visibility = View.VISIBLE
                    binding.wifiSection.visibility = View.GONE
                }
                R.id.wifiRadioButton -> {
                    binding.bluetoothSection.visibility = View.GONE
                    binding.wifiSection.visibility = View.VISIBLE
                }
            }
        }

        binding.exportButton.setOnClickListener {
            showExportOptions()
        }

        binding.importButton.setOnClickListener {
            importData()
        }

        binding.shareQrButton.setOnClickListener {
            shareViaQR()
        }

        binding.scanQrButton.setOnClickListener {
            scanQRToImport()
        }

        binding.printQrCodeButton.setOnClickListener {
            printQRCodeToEnteredMac()
        }

        binding.scanPrintersButton.setOnClickListener {
            startDeviceDiscovery()
        }

        binding.printZebraButton.setOnClickListener {
            printOnZebraPrinter()
        }

        binding.selectDeviceButton.setOnClickListener {
            startDeviceDiscovery()
        }
    }

    private fun observeStatus() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.status.collect { status ->
                binding.statusText.text = status
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

    private fun shareViaQR() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                AppLogger.logAction("QR Code Share Initiated")
                val file = File(requireContext().cacheDir, getExportFileName("json"))
                val success = viewModel.exportToJson(file)
                
                if (success) {
                    val jsonContent = file.readText()
                    
                    // For large data, show warning
                    if (jsonContent.length > 2000) {
                        AlertDialog.Builder(requireContext())
                            .setTitle("Large Database")
                            .setMessage("Database is too large for QR code. Use file export instead or export individual items.")
                            .setPositiveButton("OK", null)
                            .show()
                        AppLogger.w("QR Share", "Database too large for QR code: ${jsonContent.length} chars")
                        return@launch
                    }
                    
                    val qrBitmap = QRCodeGenerator.generateQRCode(jsonContent, 512, 512)
                    if (qrBitmap != null) {
                        binding.qrCodeImage.setImageBitmap(qrBitmap)
                        binding.qrCodeImage.visibility = View.VISIBLE
                        AppLogger.logAction("QR Code Generated Successfully")
                        Toast.makeText(requireContext(), "QR Code generated. Scan to import.", Toast.LENGTH_LONG).show()
                    } else {
                        AppLogger.e("QR Share", "Failed to generate QR bitmap")
                        Toast.makeText(requireContext(), "Failed to generate QR code", Toast.LENGTH_SHORT).show()
                    }
                }
                file.delete()
            } catch (e: Exception) {
                AppLogger.logError("QR Share", e)
                Toast.makeText(requireContext(), "Error: ${e.message}", Toast.LENGTH_SHORT).show()
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
    
    private fun getSavedPrinterMacAddress(): String? {
        return requireContext().getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_PRINTER_MAC, null)
    }
    
    private fun printDirectlyToSavedPrinter(qrBitmap: Bitmap, header: String?, footer: String?) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val savedMac = getSavedPrinterMacAddress()
                if (savedMac == null) {
                    Toast.makeText(requireContext(), "No printer configured. Please scan printer QR first.", Toast.LENGTH_LONG).show()
                    return@launch
                }
                
                android.util.Log.d("ExportImport", "Printing to saved MAC: $savedMac")
                
                // Connect directly to saved MAC address
                val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), savedMac)
                if (socket != null) {
                    val success = BluetoothPrinterHelper.printQRCode(socket, qrBitmap, header, footer)
                    if (success) {
                        Toast.makeText(requireContext(), "✅ Print sent to $savedMac", Toast.LENGTH_SHORT).show()
                    } else {
                        Toast.makeText(requireContext(), "❌ Print failed - check printer", Toast.LENGTH_SHORT).show()
                    }
                    socket.close()
                } else {
                    Toast.makeText(requireContext(), "❌ Failed to connect to printer\nMAC: $savedMac\n\nCheck:\n1. Printer is ON\n2. Bluetooth enabled\n3. In range", Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_LONG).show()
                android.util.Log.e("ExportImport", "Print error", e)
            }
        }
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
            if (permanentlyDenied.isNotEmpty()) {
                android.util.Log.w("ExportImport", "Permissions permanently denied: $permanentlyDenied")
                // Try legacy permissions instead of opening settings
                tryLegacyBluetoothPermissions()
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

        proceedWithZebraPrinting()
    }
    
    private fun tryLegacyBluetoothPermissions() {
        android.util.Log.d("ExportImport", "Trying legacy Bluetooth permissions")

        // Check legacy permissions (these might be available even if new ones are blocked)
        val legacyPermissions = arrayOf(
            "android.permission.BLUETOOTH",
            "android.permission.BLUETOOTH_ADMIN"
        )

        val missingLegacyPermissions = legacyPermissions.filter {
            val granted = ContextCompat.checkSelfPermission(requireContext(), it) == PackageManager.PERMISSION_GRANTED
            android.util.Log.d("ExportImport", "Legacy permission $it granted: $granted")
            !granted
        }

        if (missingLegacyPermissions.isNotEmpty()) {
            android.util.Log.d("ExportImport", "Legacy permissions missing: $missingLegacyPermissions")

            // For devices with MDM restrictions, try to proceed anyway if Bluetooth is enabled
            // Some Zebra SDK operations might work without explicit permissions if Bluetooth is on
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            if (bluetoothAdapter != null && bluetoothAdapter.isEnabled) {
                android.util.Log.d("ExportImport", "Bluetooth is enabled, trying to proceed without permissions")
                Toast.makeText(
                    requireContext(),
                    "Bluetooth permissions blocked, but Bluetooth is enabled. Trying to connect anyway...",
                    Toast.LENGTH_SHORT
                ).show()
                proceedWithZebraPrinting()
            } else {
                android.util.Log.w("ExportImport", "Bluetooth not enabled or not available")
                Toast.makeText(
                    requireContext(),
                    "Bluetooth permissions blocked by administrator and Bluetooth is not enabled. Please enable Bluetooth or contact IT administrator.",
                    Toast.LENGTH_LONG
                ).show()
            }
        } else {
            android.util.Log.d("ExportImport", "Legacy Bluetooth permissions are granted")
            proceedWithZebraPrinting()
        }
    }
    
    private fun proceedWithZebraPrinting() {
        val macAddress = binding.printerMacEditText.text.toString().trim()

        // Show loading
        binding.printerStatusText.text = "Connecting to Zebra printer..."
        binding.printZebraButton.isEnabled = false

        // Print test label using new simplified approach
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val zplContent = ZplContentGenerator.generateTestLabel()
                val error = zebraPrinterManager.printDocument(macAddress, zplContent)

                requireActivity().runOnUiThread {
                    binding.printZebraButton.isEnabled = true
                    if (error == null) {
                        binding.printerStatusText.text = "Print successful!"
                        Toast.makeText(requireContext(), "Print sent to Zebra printer", Toast.LENGTH_SHORT).show()
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
                
                val qrBitmap = QRCodeGenerator.generateQRCode(jsonContent, 384, 384)
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



    private fun isValidMacAddress(mac: String): Boolean {
        val macPattern = Regex("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
        return macPattern.matches(mac)
    }

    private fun getExportFileName(extension: String): String {
        val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
        return "inventory_export_${dateFormat.format(Date())}.$extension"
    }

    override fun onDestroyView() {
        super.onDestroyView()
        connectedPrinter?.let { BluetoothPrinterHelper.disconnect(it) }
        _binding = null
    }
}
