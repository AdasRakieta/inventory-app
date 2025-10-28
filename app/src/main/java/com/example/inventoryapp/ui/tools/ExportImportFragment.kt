package com.example.inventoryapp.ui.tools

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
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

class ExportImportFragment : Fragment() {

    private var _binding: FragmentExportImportBinding? = null
    private val binding get() = _binding!!

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
            }
        }
    }

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
            }
        }
    }

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
            }
        }
    }

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
    }

    override fun onDestroyView() {
        super.onDestroyView()
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
