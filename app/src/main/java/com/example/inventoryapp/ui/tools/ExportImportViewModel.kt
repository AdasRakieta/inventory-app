package com.example.inventoryapp.ui.tools

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileReader
import java.io.FileWriter

data class ExportData(
    val version: Int = 1,
    val exportedAt: Long = System.currentTimeMillis(),
    val products: List<ProductEntity>,
    val packages: List<PackageEntity>,
    val templates: List<ProductTemplateEntity>
)

class ExportImportViewModel(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository,
    private val templateRepository: ProductTemplateRepository
) : ViewModel() {

    private val _status = MutableStateFlow("")
    val status: StateFlow<String> = _status

    private val gson: Gson = GsonBuilder()
        .setPrettyPrinting()
        .create()

    suspend fun exportToJson(outputFile: File): Boolean {
        return try {
            _status.value = "Exporting data..."
            
            val products = productRepository.getAllProducts().first()
            val packages = packageRepository.getAllPackages().first()
            val templates = templateRepository.getAllTemplates().first()

            val exportData = ExportData(
                products = products,
                packages = packages,
                templates = templates
            )

            FileWriter(outputFile).use { writer ->
                gson.toJson(exportData, writer)
            }

            _status.value = "Export successful: ${products.size} products, ${packages.size} packages, ${templates.size} templates"
            true
        } catch (e: Exception) {
            _status.value = "Export failed: ${e.message}"
            false
        }
    }

    suspend fun importFromJson(inputFile: File): Boolean {
        return try {
            _status.value = "Importing data..."
            
            val exportData = FileReader(inputFile).use { reader ->
                gson.fromJson(reader, ExportData::class.java)
            }

            var importedProducts = 0
            var importedPackages = 0
            var importedTemplates = 0

            // Import templates first (no dependencies)
            exportData.templates.forEach { template ->
                try {
                    templateRepository.insertTemplate(template.copy(id = 0))
                    importedTemplates++
                } catch (e: Exception) {
                    // Skip duplicates or errors
                }
            }

            // Import products
            exportData.products.forEach { product ->
                try {
                    productRepository.insertProduct(product.copy(id = 0))
                    importedProducts++
                } catch (e: Exception) {
                    // Skip duplicates or errors (e.g., duplicate serial numbers)
                }
            }

            // Import packages
            exportData.packages.forEach { pkg ->
                try {
                    packageRepository.insertPackage(pkg.copy(id = 0))
                    importedPackages++
                } catch (e: Exception) {
                    // Skip duplicates or errors
                }
            }

            _status.value = "Import successful: $importedProducts products, $importedPackages packages, $importedTemplates templates"
            true
        } catch (e: Exception) {
            _status.value = "Import failed: ${e.message}"
            false
        }
    }

    fun clearStatus() {
        _status.value = ""
    }
}
