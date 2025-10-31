package com.example.inventoryapp.ui.tools

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.data.repository.ImportBackupRepository
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.ImportBackupEntity
import com.example.inventoryapp.data.local.entity.ImportPreview
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
    private val templateRepository: ProductTemplateRepository,
    private val backupRepository: ImportBackupRepository
) : ViewModel() {

    private val _status = MutableStateFlow("")
    val status: StateFlow<String> = _status

    private val _hasRecentBackup = MutableStateFlow(false)
    val hasRecentBackup: StateFlow<Boolean> = _hasRecentBackup

    private val gson: Gson = GsonBuilder()
        .setPrettyPrinting()
        .create()

    init {
        checkForRecentBackup()
    }

    private fun checkForRecentBackup() {
        viewModelScope.launch {
            val backup = backupRepository.getLatestBackup()
            _hasRecentBackup.value = backup != null
        }
    }

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
                writer.append("ID,Name,Category ID,Serial Number,Description,Created At,Updated At\n")
                
                // CSV Data
                products.forEach { product ->
                    writer.append("${product.id},")
                    writer.append("\"${product.name}\",")
                    writer.append("${product.categoryId ?: ""},")
                    writer.append("\"${product.serialNumber ?: ""}\",")
                    writer.append("\"${product.description ?: ""}\",")
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

    /**
     * Generate import preview showing what will be added/updated
     */
    suspend fun generateImportPreview(inputFile: File): ImportPreview? {
        return try {
            AppLogger.logAction("Generate Import Preview", "File: ${inputFile.absolutePath}")
            _status.value = "Analyzing import file..."
            
            val exportData = FileReader(inputFile).use { reader ->
                gson.fromJson(reader, ExportData::class.java)
            }

            // Get existing data
            val existingProducts = productRepository.getAllProducts().first()
            val existingPackages = packageRepository.getAllPackages().first()
            
            // Map existing items by their unique identifiers
            val existingProductSNs = existingProducts.map { it.serialNumber }.toSet()
            val existingPackageIds = existingPackages.map { it.id }.toSet()
            
            // Categorize products: new vs update
            val newProducts = mutableListOf<ProductEntity>()
            val updateProducts = mutableListOf<ProductEntity>()
            
            exportData.products.forEach { product ->
                if (existingProductSNs.contains(product.serialNumber)) {
                    updateProducts.add(product)
                } else {
                    newProducts.add(product)
                }
            }
            
            // Categorize packages: new vs update
            val newPackages = mutableListOf<PackageEntity>()
            val updatePackages = mutableListOf<PackageEntity>()
            
            exportData.packages.forEach { pkg ->
                if (existingPackageIds.contains(pkg.id)) {
                    updatePackages.add(pkg)
                } else {
                    newPackages.add(pkg)
                }
            }
            
            // Templates are always new (they use auto-increment IDs)
            val newTemplates = exportData.templates
            
            val preview = ImportPreview(
                newProducts = newProducts,
                updateProducts = updateProducts,
                newPackages = newPackages,
                updatePackages = updatePackages,
                newTemplates = newTemplates
            )
            
            _status.value = "Preview ready: ${preview.totalNewItems} new, ${preview.totalUpdateItems} to update"
            AppLogger.logAction("Import Preview Generated", _status.value)
            
            preview
        } catch (e: Exception) {
            val errorMsg = "Failed to generate preview: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Import Preview", e)
            null
        }
    }

    suspend fun importFromJson(inputFile: File): Boolean {
        return try {
            AppLogger.logAction("Import Started", "File: ${inputFile.absolutePath}")
            _status.value = "Creating backup..."
            
            // STEP 0: Create backup before import
            val backupCreated = createBackupBeforeImport("Import from ${inputFile.name}")
            if (!backupCreated) {
                _status.value = "Warning: Could not create backup, import aborted for safety"
                return false
            }
            
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
            checkForRecentBackup() // Update backup status
            true
        } catch (e: Exception) {
            val errorMsg = "Import failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Import", e)
            false
        }
    }

    /**
     * Create backup of current database state before import
     */
    private suspend fun createBackupBeforeImport(description: String): Boolean {
        return try {
            AppLogger.logAction("Backup", "Creating backup before import")
            
            // Collect current state
            val products = productRepository.getAllProducts().first()
            val packages = packageRepository.getAllPackages().first()
            val templates = templateRepository.getAllTemplates().first()
            
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

            val backupData = ExportData(
                products = products,
                packages = packages,
                templates = templates,
                packageProductRelations = packageProductRelations
            )

            val backupJson = gson.toJson(backupData)
            
            val backup = ImportBackupEntity(
                backupJson = backupJson,
                importDescription = description,
                productsCount = products.size,
                packagesCount = packages.size,
                templatesCount = templates.size
            )
            
            backupRepository.insertBackup(backup)
            
            // Keep only last 5 backups to save space
            backupRepository.pruneOldBackups(5)
            
            AppLogger.logAction("Backup Created", "Products: ${products.size}, Packages: ${packages.size}, Templates: ${templates.size}")
            true
        } catch (e: Exception) {
            AppLogger.logError("Backup Creation Failed", e)
            false
        }
    }

    /**
     * Undo last import by restoring from backup
     */
    suspend fun undoLastImport(): Boolean {
        return try {
            AppLogger.logAction("Undo Import", "Starting...")
            _status.value = "Restoring from backup..."
            
            val backup = backupRepository.getLatestBackup()
            if (backup == null) {
                _status.value = "No backup found to restore"
                return false
            }
            
            val backupData = gson.fromJson(backup.backupJson, ExportData::class.java)
            
            // Clear current data
            _status.value = "Clearing current data..."
            
            // Delete all current entries
            productRepository.getAllProducts().first().forEach { product ->
                productRepository.deleteProduct(product)
            }
            packageRepository.getAllPackages().first().forEach { pkg ->
                packageRepository.deletePackage(pkg)
            }
            templateRepository.getAllTemplates().first().forEach { template ->
                templateRepository.deleteTemplate(template)
            }
            
            // Restore from backup
            _status.value = "Restoring data from backup..."
            
            var restoredProducts = 0
            var restoredPackages = 0
            var restoredTemplates = 0
            var restoredRelations = 0
            
            // Restore templates
            backupData.templates.forEach { template ->
                try {
                    templateRepository.insertTemplate(template.copy(id = 0))
                    restoredTemplates++
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore template: ${template.name}", e)
                }
            }
            
            // Restore products with ID mapping
            val productIdMap = mutableMapOf<Long, Long>()
            backupData.products.forEach { product ->
                try {
                    val oldId = product.id
                    val newId = productRepository.insertProduct(product.copy(id = 0))
                    productIdMap[oldId] = newId
                    restoredProducts++
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore product: ${product.name}", e)
                }
            }
            
            // Restore packages with ID mapping
            val packageIdMap = mutableMapOf<Long, Long>()
            backupData.packages.forEach { pkg ->
                try {
                    val oldId = pkg.id
                    val newId = packageRepository.insertPackage(pkg.copy(id = 0))
                    packageIdMap[oldId] = newId
                    restoredPackages++
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore package: ${pkg.name}", e)
                }
            }
            
            // Restore relations
            backupData.packageProductRelations.forEach { relation ->
                try {
                    val newPackageId = packageIdMap[relation.packageId]
                    val newProductId = productIdMap[relation.productId]
                    
                    if (newPackageId != null && newProductId != null) {
                        packageRepository.addProductToPackage(newPackageId, newProductId)
                        restoredRelations++
                    }
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore relation", e)
                }
            }
            
            // Delete the used backup
            backupRepository.deleteBackup(backup)
            
            val message = "Undo successful: Restored $restoredProducts products, $restoredPackages packages, $restoredTemplates templates, $restoredRelations relations"
            _status.value = message
            AppLogger.logAction("Undo Completed", message)
            checkForRecentBackup() // Update backup status
            true
        } catch (e: Exception) {
            val errorMsg = "Undo failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Undo", e)
            false
        }
    }

    fun clearStatus() {
        _status.value = ""
    }
}
