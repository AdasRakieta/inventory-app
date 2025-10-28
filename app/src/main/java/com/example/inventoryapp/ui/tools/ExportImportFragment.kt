package com.example.inventoryapp.ui.tools

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Environment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.example.inventoryapp.databinding.FragmentExportImportBinding
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class ExportImportFragment : Fragment() {

    private var _binding: FragmentExportImportBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: ExportImportViewModel

    private val createFileLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            result.data?.data?.let { uri ->
                // Handle file creation for export
                viewLifecycleOwner.lifecycleScope.launch {
                    val file = File(requireContext().cacheDir, getExportFileName())
                    val success = viewModel.exportToJson(file)
                    if (success) {
                        // Copy from cache to selected location
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
                // Handle file selection for import
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
            exportData()
        }

        binding.importButton.setOnClickListener {
            importData()
        }
    }

    private fun observeStatus() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.status.collect { status ->
                binding.statusText.text = status
            }
        }
    }

    private fun exportData() {
        // Use simplified file export to Downloads folder
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val file = File(downloadsDir, getExportFileName())
                
                val success = viewModel.exportToJson(file)
                if (success) {
                    Toast.makeText(
                        requireContext(),
                        "Exported to: ${file.absolutePath}",
                        Toast.LENGTH_LONG
                    ).show()
                }
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    "Export failed: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

    private fun importData() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
        }
        openFileLauncher.launch(intent)
    }

    private fun getExportFileName(): String {
        val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
        return "inventory_export_${dateFormat.format(Date())}.json"
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
