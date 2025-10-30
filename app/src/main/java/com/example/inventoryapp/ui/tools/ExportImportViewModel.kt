package com.example.inventoryapp.ui.tools

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.utils.AppLogger
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileReader
import java.io.FileWriter

/**
 * Enhanced export data structure with relationships
 */
data class ExportData(
    val version: Int = 2, // Incremented version for new structure
    val exportedAt: Long = System.currentTimeMillis(),
    val products: List<ProductEntity>,
    val packages: List<PackageEntity>,
    val templates: List<ProductTemplateEntity>,
    val packageProductRelations: List<PackageProductCrossRef> = emptyList() // Product-Package relations
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
            AppLogger.logAction("Export Started", "File: ${outputFile.absolutePath}")
            _status.value = "Exporting data..."
            
            val products = productRepository.getAllProducts().first()
            val packages = packageRepository.getAllPackages().first()
            val templates = templateRepository.getAllTemplates().first()
            
            // Collect all package-product relationships
            val packageProductRelations = mutableListOf<PackageProductCrossRef>()
            packages.forEach { pkg ->
                val productsInPackage = packageRepository.getProductsInPackage(pkg.id).first()
                productsInPackage.forEach { product ->
                    packageProductRelations.add(
                        PackageProductCrossRef(
                            packageId = pkg.id,
                            productId = product.id
                        )
                    )
                }
            }

            val exportData = ExportData(
                products = products,
                packages = packages,
                templates = templates,
                packageProductRelations = packageProductRelations
            )

            // Ensure parent directory exists
            outputFile.parentFile?.mkdirs()

            FileWriter(outputFile).use { writer ->
                gson.toJson(exportData, writer)
            }

            val message = "Export successful: ${products.size} products, ${packages.size} packages, ${templates.size} templates, ${packageProductRelations.size} relations"
            _status.value = message
            AppLogger.logAction("Export Completed", message)
            true
        } catch (e: Exception) {
            val errorMsg = "Export failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Export", e)
            false
        }
    }
    
    suspend fun exportToCsv(outputFile: File): Boolean {
        return try {
            AppLogger.logAction("CSV Export Started", "File: ${outputFile.absolutePath}")
            _status.value = "Exporting to CSV..."
            
            val products = productRepository.getAllProducts().first()
            
            // Ensure parent directory exists
            outputFile.parentFile?.mkdirs()
            
            FileWriter(outputFile).use { writer ->
                // CSV Header
                writer.append("ID,Name,Category ID,Serial Number,Created At,Updated At\n")
                
                // CSV Data
                products.forEach { product ->
                    writer.append("${product.id},")
                    writer.append("\"${product.name}\",")
                    writer.append("${product.categoryId ?: ""},")
                    writer.append("\"${product.serialNumber ?: ""}\",")
                    writer.append("${product.createdAt},")
                    writer.append("${product.updatedAt}\n")
                }
            }
            
            val message = "CSV export successful: ${products.size} products"
            _status.value = message
            AppLogger.logAction("CSV Export Completed", message)
            true
        } catch (e: Exception) {
            val errorMsg = "CSV export failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("CSV Export", e)
            false
        }
    }

    suspend fun importFromJson(inputFile: File): Boolean {
        return try {
            AppLogger.logAction("Import Started", "File: ${inputFile.absolutePath}")
            _status.value = "Importing data..."
            
            val exportData = FileReader(inputFile).use { reader ->
                gson.fromJson(reader, ExportData::class.java)
            }

            var importedProducts = 0
            var importedPackages = 0
            var importedTemplates = 0
            var importedRelations = 0

            // Step 1: Import templates first (no dependencies)
            exportData.templates.forEach { template ->
                try {
                    templateRepository.insertTemplate(template.copy(id = 0))
                    importedTemplates++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped template: ${template.name}", e)
                }
            }

            // Step 2: Import products and track ID mapping (old ID -> new ID)
            val productIdMap = mutableMapOf<Long, Long>()
            exportData.products.forEach { product ->
                try {
                    val oldId = product.id
                    val newId = productRepository.insertProduct(product.copy(id = 0))
                    productIdMap[oldId] = newId
                    importedProducts++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped product: ${product.name}", e)
                }
            }

            // Step 3: Import packages and track ID mapping (old ID -> new ID)
            val packageIdMap = mutableMapOf<Long, Long>()
            exportData.packages.forEach { pkg ->
                try {
                    val oldId = pkg.id
                    val newId = packageRepository.insertPackage(pkg.copy(id = 0))
                    packageIdMap[oldId] = newId
                    importedPackages++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped package: ${pkg.name}", e)
                }
            }

            // Step 4: Import package-product relationships using mapped IDs
            exportData.packageProductRelations.forEach { relation ->
                try {
                    val newPackageId = packageIdMap[relation.packageId]
                    val newProductId = productIdMap[relation.productId]
                    
                    if (newPackageId != null && newProductId != null) {
                        packageRepository.addProductToPackage(newPackageId, newProductId)
                        importedRelations++
                    } else {
                        AppLogger.w("Import", "Skipped relation - package ${relation.packageId} or product ${relation.productId} not found")
                    }
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped relation: package ${relation.packageId} -> product ${relation.productId}", e)
                }
            }

            val message = "Import successful: $importedProducts products, $importedPackages packages, $importedTemplates templates, $importedRelations relations"
            _status.value = message
            AppLogger.logAction("Import Completed", message)
            true
        } catch (e: Exception) {
            val errorMsg = "Import failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Import", e)
            false
        }
    }

    fun clearStatus() {
        _status.value = ""
    }
}
