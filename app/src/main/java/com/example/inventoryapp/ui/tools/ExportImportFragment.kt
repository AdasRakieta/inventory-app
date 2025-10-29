package com.example.inventoryapp.ui.tools

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
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
import com.google.gson.GsonBuilder
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class ExportImportFragment : Fragment() {

    private var _binding: FragmentExportImportBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ExportImportViewModel
    private var connectedPrinter: BluetoothSocket? = null
    
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
        if (allGranted) {
            android.util.Log.d("ExportImport", "Bluetooth permissions granted, proceeding with print")
            proceedWithPrinting()
        } else {
            Toast.makeText(
                requireContext(), 
                "Bluetooth permissions are required for printing to Bluetooth printer",
                Toast.LENGTH_LONG
            ).show()
            android.util.Log.w("ExportImport", "Bluetooth permissions denied")
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
        
        viewModel = ExportImportViewModel(
            productRepository,
            packageRepository,
            templateRepository
        )
    }

    private fun setupButtons() {
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
        // For SDK 30 (Android 11): Bluetooth permissions are normal permissions, auto-granted at install
        // Android 12+ (API 31+) would require BLUETOOTH_SCAN and BLUETOOTH_CONNECT runtime permissions
        // but this app targets SDK 30, so we directly proceed
        android.util.Log.d("ExportImport", "Bluetooth permissions check: SDK 30, auto-granted")
        proceedWithPrinting()
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
