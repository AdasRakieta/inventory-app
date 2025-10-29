package com.example.inventoryapp.ui.tools

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
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
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class ExportImportFragment : Fragment() {

    private var _binding: FragmentExportImportBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ExportImportViewModel
    private var connectedPrinter: BluetoothSocket? = null

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

    private val bluetoothPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val allGranted = permissions.values.all { it }
        if (allGranted) {
            scanForPrinterQR()
        } else {
            Toast.makeText(requireContext(), "Bluetooth permissions required", Toast.LENGTH_SHORT).show()
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
        viewModel = ExportImportViewModel(
            ProductRepository(database.productDao()),
            PackageRepository(database.packageDao(), database.productDao()),
            ProductTemplateRepository(database.productTemplateDao())
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

        binding.scanPrinterQrButton.setOnClickListener {
            requestBluetoothPermissionsAndScan()
        }

        binding.printTestButton.setOnClickListener {
            printTestQRCode()
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
        // Navigate to scanner
        findNavController().navigate(R.id.scannerFragment)
        Toast.makeText(requireContext(), "Scan QR code to import data", Toast.LENGTH_SHORT).show()
    }

    private fun requestBluetoothPermissionsAndScan() {
        // For targetSdk 30, always use legacy Bluetooth permissions
        val permissions = arrayOf(
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN
        )

        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(requireContext(), it) != PackageManager.PERMISSION_GRANTED
        }

        if (missingPermissions.isEmpty()) {
            scanForPrinterQR()
        } else {
            bluetoothPermissionLauncher.launch(missingPermissions.toTypedArray())
        }
    }

    private fun scanForPrinterQR() {
        // Navigate to scanner to scan printer MAC address QR
        Toast.makeText(requireContext(), "Scan printer QR code with MAC address", Toast.LENGTH_LONG).show()
        // TODO: Implement QR scanner result handling for MAC address
        // For now, show a sample connection
        connectToPrinterViaMac("00:11:22:33:44:55")
    }

    private fun connectToPrinterViaMac(macAddress: String) {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                binding.printerStatusText.text = "Connecting to printer..."
                
                val socket = BluetoothPrinterHelper.connectToPrinter(requireContext(), macAddress)
                if (socket != null) {
                    connectedPrinter = socket
                    binding.printerStatusText.text = "Connected: $macAddress"
                    binding.printTestButton.isEnabled = true
                    Toast.makeText(requireContext(), "Printer connected successfully", Toast.LENGTH_SHORT).show()
                } else {
                    binding.printerStatusText.text = "Failed to connect"
                    binding.printTestButton.isEnabled = false
                    Toast.makeText(requireContext(), "Failed to connect to printer", Toast.LENGTH_SHORT).show()
                }
            } catch (e: Exception) {
                binding.printerStatusText.text = "Error: ${e.message}"
                binding.printTestButton.isEnabled = false
                Toast.makeText(requireContext(), "Connection error: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun printTestQRCode() {
        connectedPrinter?.let { socket ->
            viewLifecycleOwner.lifecycleScope.launch {
                try {
                    val testData = mapOf(
                        "type" to "test",
                        "timestamp" to System.currentTimeMillis(),
                        "message" to "Test QR Code from Inventory App"
                    )
                    
                    val qrBitmap = QRCodeGenerator.generateQRCode(testData, 384, 384)
                    if (qrBitmap != null) {
                        val success = BluetoothPrinterHelper.printQRCode(
                            socket,
                            qrBitmap,
                            "INVENTORY APP",
                            "Test Print"
                        )
                        
                        if (success) {
                            Toast.makeText(requireContext(), "Test QR code printed", Toast.LENGTH_SHORT).show()
                        } else {
                            Toast.makeText(requireContext(), "Print failed", Toast.LENGTH_SHORT).show()
                        }
                        qrBitmap.recycle()
                    } else {
                        Toast.makeText(requireContext(), "Failed to generate QR code", Toast.LENGTH_SHORT).show()
                    }
                } catch (e: Exception) {
                    Toast.makeText(requireContext(), "Print error: ${e.message}", Toast.LENGTH_SHORT).show()
                }
            }
        } ?: Toast.makeText(requireContext(), "No printer connected", Toast.LENGTH_SHORT).show()
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
