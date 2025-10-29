package com.example.inventoryapp.ui.tools

import android.Manifest
<<<<<<< HEAD
import android.content.pm.PackageManager
=======
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
<<<<<<< HEAD
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.setFragmentResultListener
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.example.inventoryapp.databinding.FragmentExportImportBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.utils.QrShareHelper
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
=======
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
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91

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
                    val file = File(requireContext().cacheDir, getExportFileName())
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

    private val gson: Gson = GsonBuilder().setPrettyPrinting().create()

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
<<<<<<< HEAD

        binding.exportButton.setOnClickListener { onExportClicked() }
        binding.importButton.setOnClickListener { onImportLatestClicked() }
        binding.importFromFileButton.setOnClickListener { onImportFromFileClicked() }
        binding.importFromQrButton.setOnClickListener { onImportFromQrClicked() }

        // Default mode JSON
        binding.exportModeToggle.check(binding.modeJson.id)
        
        // Request storage permissions
        checkAndRequestStoragePermissions()
        
        // Setup QR scan result listener
        setFragmentResultListener("qr_scan_result") { _, bundle ->
            val scannedData = bundle.getString("scan_data")
            if (!scannedData.isNullOrEmpty()) {
                viewLifecycleOwner.lifecycleScope.launch {
                    try {
                        importJson(scannedData)
                        binding.statusText.text = "Import completed from QR scan"
                        Toast.makeText(requireContext(), "Data imported from QR", Toast.LENGTH_SHORT).show()
                    } catch (e: Exception) {
                        binding.statusText.text = "QR import failed: ${e.message}"
                        Toast.makeText(requireContext(), "Failed to import QR data", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
    }
    
    private fun checkAndRequestStoragePermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val permissions = mutableListOf<String>()
            
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            }
            
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            
            if (permissions.isNotEmpty()) {
                ActivityCompat.requestPermissions(requireActivity(), permissions.toTypedArray(), REQ_STORAGE_PERMISSION)
            }
        }
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_STORAGE_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                Toast.makeText(requireContext(), "Storage permissions granted", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(requireContext(), "Storage permissions required for export/import", Toast.LENGTH_LONG).show()
=======
        
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
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
            }
        }
    }

<<<<<<< HEAD
    private fun onExportClicked() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val db = AppDatabase.getDatabase(requireContext())
                val products = db.productDao().getAllProducts().first()
                val packages = db.packageDao().getAllPackages().first()
                // Cross refs as snapshot: fetch all pairs by joining distinct package ids
                val crossRefs = withContext(Dispatchers.IO) {
                    val refs = mutableListOf<PackageProductCrossRef>()
                    packages.forEach { pkg ->
                        db.packageDao().getProductsInPackage(pkg.id).first().forEach { product ->
                            refs.add(PackageProductCrossRef(packageId = pkg.id, productId = product.id))
                        }
                    }
                    refs
                }
                val templates = db.productTemplateDao().getAllTemplates().first()

                val snapshot = ExportSnapshot(products, packages, crossRefs, templates)
                
                // Create Documents/inventory folder on real external storage
                val externalStorage = Environment.getExternalStorageDirectory()
                val inventoryDir = File(externalStorage, "Documents/inventory")
                if (!inventoryDir.exists()) {
                    inventoryDir.mkdirs()
                }
                val outDir = inventoryDir
                val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())

                when (binding.exportModeToggle.checkedButtonId) {
                    binding.modeJson.id -> {
                        val json = gson.toJson(snapshot)
                        val outFile = File(outDir, "inventory_export_$timestamp.json")
                        withContext(Dispatchers.IO) { outFile.writeText(json) }
                        binding.statusText.text = "Exported JSON: ${outFile.absolutePath}"
                    }
                    binding.modeCsv.id -> {
                        val outFile = File(outDir, "inventory_export_$timestamp.csv")
                        withContext(Dispatchers.IO) { outFile.writeText(snapshot.toCsv()) }
                        binding.statusText.text = "Exported CSV: ${outFile.absolutePath}"
                    }
                    binding.modeQr.id -> {
                        // Generate QR with compact JSON (may be truncated for very large data)
                        val json = gson.toJson(snapshot)
                        QrShareHelper.showQrOrPrint(requireActivity(), json)
                        binding.statusText.text = "QR shown/printed"
                    }
                }

                Toast.makeText(requireContext(), "Export completed", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                binding.statusText.text = "Export failed: ${e.message}"
                Toast.makeText(requireContext(), "Export failed", Toast.LENGTH_SHORT).show()
=======
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
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
            }
        }
    }

<<<<<<< HEAD
    private fun onImportLatestClicked() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val externalStorage = Environment.getExternalStorageDirectory()
                val inventoryDir = File(externalStorage, "Documents/inventory")
                val inDir = if (inventoryDir.exists()) inventoryDir else requireContext().getExternalFilesDir(null) ?: requireContext().filesDir
                val latest = inDir.listFiles { f -> f.isFile && f.name.startsWith("inventory_export_") && f.name.endsWith(".json") }
                    ?.maxByOrNull { it.lastModified() }
                if (latest == null) {
                    binding.statusText.text = "No export file found"
                    Toast.makeText(requireContext(), "No export found", Toast.LENGTH_SHORT).show()
                    return@launch
                }
                val json = withContext(Dispatchers.IO) { latest.readText() }
                val snapshot = gson.fromJson(json, ExportSnapshot::class.java)

                val db = AppDatabase.getDatabase(requireContext())

                withContext(Dispatchers.IO) {
                    // Simple merge: insert products whose serialNumber does not exist
                    snapshot.products.forEach { p ->
                        if (p.serialNumber != null) {
                            val exists = db.productDao().isSerialNumberExists(p.serialNumber) > 0
                            if (!exists) {
                                db.productDao().insertProduct(
                                    p.copy(id = 0) // let Room assign new IDs
                                )
                            }
                        } else {
                            // No serial: insert as new item
                            db.productDao().insertProduct(p.copy(id = 0))
                        }
                    }

                    // Insert packages (by name uniqueness simplistic)
                    snapshot.packages.forEach { pkg ->
                        db.packageDao().insertPackage(pkg.copy(id = 0))
                    }

                    // We need new IDs to recreate cross refs; skip if ids unknown (basic import)
                    // Note: Full mapping is beyond minimal scope here.

                    // Insert templates (by name uniqueness simplistic)
                    snapshot.templates.forEach { t ->
                        db.productTemplateDao().insertTemplate(t.copy(id = 0))
                    }
                }

                binding.statusText.text = "Import completed from: ${latest.absolutePath}"
                Toast.makeText(requireContext(), "Import completed", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                binding.statusText.text = "Import failed: ${e.message}"
                Toast.makeText(requireContext(), "Import failed", Toast.LENGTH_SHORT).show()
=======
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
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
            }
        }
    }

<<<<<<< HEAD
    private fun onImportFromFileClicked() {
        // Minimal picker using ACTION_GET_CONTENT
        val intent = android.content.Intent(android.content.Intent.ACTION_GET_CONTENT).apply {
            type = "*/*"
            putExtra(android.content.Intent.EXTRA_MIME_TYPES, arrayOf("application/json", "text/csv"))
        }
        startActivityForResult(intent, REQ_IMPORT_FILE)
    }

    private fun onImportFromQrClicked() {
        // Navigate to scanner with QR import mode
        val action = ExportImportFragmentDirections.actionExportImportToScanner("qr_import")
        findNavController().navigate(action)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQ_IMPORT_FILE && resultCode == android.app.Activity.RESULT_OK) {
            val uri = data?.data ?: return
            viewLifecycleOwner.lifecycleScope.launch {
                try {
                    val content = withContext(Dispatchers.IO) {
                        requireContext().contentResolver.openInputStream(uri)?.use { it.readBytes().toString(Charsets.UTF_8) }
                            ?: ""
                    }
                    if (uri.toString().endsWith(".csv")) {
                        importCsv(content)
                    } else {
                        importJson(content)
                    }
                    binding.statusText.text = "Import completed from picker"
                } catch (e: Exception) {
                    binding.statusText.text = "Import failed: ${e.message}"
                }
            }
        }
    }

    private fun importJson(json: String) {
        val snapshot = gson.fromJson(json, ExportSnapshot::class.java)
        // Reuse merge logic
        viewLifecycleOwner.lifecycleScope.launch {
            val db = AppDatabase.getDatabase(requireContext())
            withContext(Dispatchers.IO) {
                snapshot.products.forEach { p ->
                    if (p.serialNumber != null) {
                        val exists = db.productDao().isSerialNumberExists(p.serialNumber) > 0
                        if (!exists) db.productDao().insertProduct(p.copy(id = 0))
                    } else db.productDao().insertProduct(p.copy(id = 0))
                }
                snapshot.packages.forEach { pkg -> db.packageDao().insertPackage(pkg.copy(id = 0)) }
                snapshot.templates.forEach { t -> db.productTemplateDao().insertTemplate(t.copy(id = 0)) }
            }
        }
    }

    private fun importCsv(csv: String) {
        // Very minimal CSV support: products only (name,categoryId,serialNumber,scannerId)
        val lines = csv.lines().filter { it.isNotBlank() }
        if (lines.isEmpty()) return
        val header = lines.first().split(',').map { it.trim().toLowerCase(Locale.US) }
        val idxName = header.indexOf("name")
        val idxCat = header.indexOf("categoryid")
        val idxSn = header.indexOf("serialnumber")
        val idxSc = header.indexOf("scannerid")
        viewLifecycleOwner.lifecycleScope.launch {
            val db = AppDatabase.getDatabase(requireContext())
            withContext(Dispatchers.IO) {
                lines.drop(1).forEach { line ->
                    val cols = line.split(',')
                    val name = cols.getOrNull(idxName)?.trim().orEmpty()
                    val catId = cols.getOrNull(idxCat)?.toLongOrNull()
                    val sn = cols.getOrNull(idxSn)?.trim()
                    val sc = cols.getOrNull(idxSc)?.trim()
                    if (name.isNotEmpty()) {
                        if (!sn.isNullOrEmpty()) {
                            val exists = db.productDao().isSerialNumberExists(sn) > 0
                            if (exists) return@forEach
                        }
                        db.productDao().insertProduct(
                            ProductEntity(name = name, categoryId = catId, serialNumber = sn, scannerId = sc)
                        )
                    }
                }
            }
        }
    }

    companion object {
        private const val REQ_IMPORT_FILE = 2001
        private const val REQ_STORAGE_PERMISSION = 2002
        private const val REQ_SCAN_QR = 2003
=======
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
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN
            )
        }

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
                
                val socket = BluetoothPrinterHelper.connectToPrinter(macAddress)
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
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
    }

    override fun onDestroyView() {
        super.onDestroyView()
        connectedPrinter?.let { BluetoothPrinterHelper.disconnect(it) }
        _binding = null
    }
}

data class ExportSnapshot(
    val products: List<ProductEntity>,
    val packages: List<PackageEntity>,
    val packageProductRefs: List<PackageProductCrossRef>,
    val templates: List<ProductTemplateEntity>
)

// Simple CSV export for products; headers: name,categoryId,serialNumber,scannerId
fun ExportSnapshot.toCsv(): String {
    val sb = StringBuilder()
    sb.append("name,categoryId,serialNumber,scannerId\n")
    products.forEach { p ->
        val name = p.name.replace("\n", " ").replace(",", " ")
        val cat = p.categoryId?.toString() ?: ""
        val sn = p.serialNumber?.replace(",", " ") ?: ""
        val sc = p.scannerId?.replace(",", " ") ?: ""
        sb.append("$name,$cat,$sn,$sc\n")
    }
    return sb.toString()
}
