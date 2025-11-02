package com.example.inventoryapp.ui.tools

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import com.example.inventoryapp.data.repository.ImportBackupRepository
import com.example.inventoryapp.data.repository.BoxRepository
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.BoxEntity
import com.example.inventoryapp.data.local.entities.BoxProductCrossRef
import com.example.inventoryapp.data.local.entities.ContractorEntity
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
    val version: Int = 3, // Incremented version for boxes, contractors and all relations
    val exportedAt: Long = System.currentTimeMillis(),
    val products: List<ProductEntity>,
    val packages: List<PackageEntity>,
    val templates: List<ProductTemplateEntity>,
    val boxes: List<BoxEntity>,
    val contractors: List<ContractorEntity>,
    val packageProductRelations: List<PackageProductCrossRef> = emptyList(), // Product-Package relations
    val boxProductRelations: List<BoxProductCrossRef> = emptyList() // Product-Box relations
)

class ExportImportViewModel(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository,
    private val templateRepository: ProductTemplateRepository,
    private val backupRepository: ImportBackupRepository,
    private val boxRepository: BoxRepository,
    private val contractorRepository: ContractorRepository
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
            val boxes = boxRepository.getAllBoxes().first()
            val contractors = contractorRepository.getAllContractors().first()
            
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
            
            // Collect all box-product relationships
            val boxProductRelations = mutableListOf<BoxProductCrossRef>()
            boxes.forEach { box ->
                val productsInBox = boxRepository.getProductsInBox(box.id).first()
                productsInBox.forEach { product ->
                    boxProductRelations.add(
                        BoxProductCrossRef(
                            boxId = box.id,
                            productId = product.id
                        )
                    )
                }
            }

            val exportData = ExportData(
                products = products,
                packages = packages,
                templates = templates,
                boxes = boxes,
                contractors = contractors,
                packageProductRelations = packageProductRelations,
                boxProductRelations = boxProductRelations
            )

            // Ensure parent directory exists
            outputFile.parentFile?.mkdirs()

            FileWriter(outputFile).use { writer ->
                gson.toJson(exportData, writer)
            }

            val message = "Export successful: ${products.size} products, ${packages.size} packages, ${boxes.size} boxes, ${contractors.size} contractors, ${templates.size} templates, ${packageProductRelations.size} pkg-relations, ${boxProductRelations.size} box-relations"
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
            val contractors = contractorRepository.getAllContractors().first()
            
            // Ensure parent directory exists
            outputFile.parentFile?.mkdirs()
            
            FileWriter(outputFile).use { writer ->
                // CSV Header with extended information
                writer.append("Product ID,")
                writer.append("Product Name,")
                writer.append("Category ID,")
                writer.append("Serial Number,")
                writer.append("Description,")
                writer.append("Quantity,")
                writer.append("Package ID,")
                writer.append("Package Name,")
                writer.append("Contractor ID,")
                writer.append("Contractor Name,")
                writer.append("Box ID,")
                writer.append("Box Name,")
                writer.append("Box Description,")
                writer.append("Created At,")
                writer.append("Updated At\n")
                
                // CSV Data
                products.forEach { product ->
                    // Find package for this product
                    val productPackage = try {
                        packageRepository.getPackageByProductId(product.id).first()
                    } catch (e: Exception) {
                        null
                    }
                    
                    // Find contractor for the package
                    val contractor = if (productPackage?.contractorId != null) {
                        contractors.find { it.id == productPackage.contractorId }
                    } else {
                        null
                    }
                    
                    // Find box for this product
                    val productBox = try {
                        boxRepository.getBoxByProductId(product.id).first()
                    } catch (e: Exception) {
                        null
                    }
                    
                    writer.append("${product.id},")
                    writer.append("\"${product.name}\",")
                    writer.append("${product.categoryId ?: ""},")
                    writer.append("\"${product.serialNumber ?: ""}\",")
                    writer.append("\"${product.description ?: ""}\",")
                    writer.append("${product.quantity},")
                    writer.append("${productPackage?.id ?: ""},")
                    writer.append("\"${productPackage?.name ?: ""}\",")
                    writer.append("${contractor?.id ?: ""},")
                    writer.append("\"${contractor?.name ?: ""}\",")
                    writer.append("${productBox?.id ?: ""},")
                    writer.append("\"${productBox?.name ?: ""}\",")
                    writer.append("\"${productBox?.description ?: ""}\",")
                    writer.append("${product.createdAt},")
                    writer.append("${product.updatedAt}\n")
                }
            }
            
            val message = "CSV export successful: ${products.size} products with package/box/contractor info"
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
            var importedBoxes = 0
            var importedContractors = 0
            var importedPackageRelations = 0
            var importedBoxRelations = 0

            // Step 1: Import contractors first (no dependencies)
            val contractorIdMap = mutableMapOf<Long, Long>()
            exportData.contractors.forEach { contractor ->
                try {
                    val oldId = contractor.id
                    val newId = contractorRepository.insertContractor(contractor.copy(id = 0))
                    contractorIdMap[oldId] = newId
                    importedContractors++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped contractor: ${contractor.name}", e)
                }
            }

            // Step 2: Import templates (no dependencies)
            exportData.templates.forEach { template ->
                try {
                    templateRepository.insertTemplate(template.copy(id = 0))
                    importedTemplates++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped template: ${template.name}", e)
                }
            }

            // Step 3: Import products and track ID mapping (old ID -> new ID)
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

            // Step 4: Import packages and track ID mapping (old ID -> new ID)
            val packageIdMap = mutableMapOf<Long, Long>()
            exportData.packages.forEach { pkg ->
                try {
                    val oldId = pkg.id
                    // Remap contractor ID if exists
                    val newContractorId = pkg.contractorId?.let { contractorIdMap[it] }
                    val newId = packageRepository.insertPackage(
                        pkg.copy(id = 0, contractorId = newContractorId)
                    )
                    packageIdMap[oldId] = newId
                    importedPackages++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped package: ${pkg.name}", e)
                }
            }

            // Step 5: Import boxes and track ID mapping
            val boxIdMap = mutableMapOf<Long, Long>()
            exportData.boxes.forEach { box ->
                try {
                    val oldId = box.id
                    val newId = boxRepository.insertBox(box.copy(id = 0))
                    boxIdMap[oldId] = newId
                    importedBoxes++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped box: ${box.name}", e)
                }
            }

            // Step 6: Import package-product relationships using mapped IDs
            exportData.packageProductRelations.forEach { relation ->
                try {
                    val newPackageId = packageIdMap[relation.packageId]
                    val newProductId = productIdMap[relation.productId]
                    
                    if (newPackageId != null && newProductId != null) {
                        packageRepository.addProductToPackage(newPackageId, newProductId)
                        importedPackageRelations++
                    } else {
                        AppLogger.w("Import", "Skipped pkg relation - package ${relation.packageId} or product ${relation.productId} not found")
                    }
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped pkg relation: package ${relation.packageId} -> product ${relation.productId}", e)
                }
            }

            // Step 7: Import box-product relationships using mapped IDs
            exportData.boxProductRelations.forEach { relation ->
                try {
                    val newBoxId = boxIdMap[relation.boxId]
                    val newProductId = productIdMap[relation.productId]
                    
                    if (newBoxId != null && newProductId != null) {
                        boxRepository.addProductToBox(newBoxId, newProductId)
                        importedBoxRelations++
                    } else {
                        AppLogger.w("Import", "Skipped box relation - box ${relation.boxId} or product ${relation.productId} not found")
                    }
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped box relation: box ${relation.boxId} -> product ${relation.productId}", e)
                }
            }

            val message = "Import successful: $importedProducts products, $importedPackages packages, $importedBoxes boxes, $importedContractors contractors, $importedTemplates templates, $importedPackageRelations pkg-relations, $importedBoxRelations box-relations"
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
            val boxes = boxRepository.getAllBoxes().first()
            val contractors = contractorRepository.getAllContractors().first()
            
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
            
            val boxProductRelations = mutableListOf<BoxProductCrossRef>()
            boxes.forEach { box ->
                val productsInBox = boxRepository.getProductsInBox(box.id).first()
                productsInBox.forEach { product ->
                    boxProductRelations.add(
                        BoxProductCrossRef(
                            boxId = box.id,
                            productId = product.id
                        )
                    )
                }
            }

            val backupData = ExportData(
                products = products,
                packages = packages,
                templates = templates,
                boxes = boxes,
                contractors = contractors,
                packageProductRelations = packageProductRelations,
                boxProductRelations = boxProductRelations
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
            boxRepository.getAllBoxes().first().forEach { box ->
                boxRepository.deleteBox(box)
            }
            contractorRepository.getAllContractors().first().forEach { contractor ->
                contractorRepository.deleteContractor(contractor)
            }
            
            // Restore from backup
            _status.value = "Restoring data from backup..."
            
            var restoredProducts = 0
            var restoredPackages = 0
            var restoredTemplates = 0
            var restoredBoxes = 0
            var restoredContractors = 0
            var restoredPackageRelations = 0
            var restoredBoxRelations = 0
            
            // Restore contractors first (no dependencies)
            val contractorIdMap = mutableMapOf<Long, Long>()
            backupData.contractors.forEach { contractor ->
                try {
                    val oldId = contractor.id
                    val newId = contractorRepository.insertContractor(contractor.copy(id = 0))
                    contractorIdMap[oldId] = newId
                    restoredContractors++
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore contractor: ${contractor.name}", e)
                }
            }
            
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
            
            // Restore packages with ID mapping and contractor mapping
            val packageIdMap = mutableMapOf<Long, Long>()
            backupData.packages.forEach { pkg ->
                try {
                    val oldId = pkg.id
                    val newContractorId = pkg.contractorId?.let { contractorIdMap[it] }
                    val newId = packageRepository.insertPackage(
                        pkg.copy(id = 0, contractorId = newContractorId)
                    )
                    packageIdMap[oldId] = newId
                    restoredPackages++
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore package: ${pkg.name}", e)
                }
            }
            
            // Restore boxes with ID mapping
            val boxIdMap = mutableMapOf<Long, Long>()
            backupData.boxes.forEach { box ->
                try {
                    val oldId = box.id
                    val newId = boxRepository.insertBox(box.copy(id = 0))
                    boxIdMap[oldId] = newId
                    restoredBoxes++
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore box: ${box.name}", e)
                }
            }
            
            // Restore package-product relations
            backupData.packageProductRelations.forEach { relation ->
                try {
                    val newPackageId = packageIdMap[relation.packageId]
                    val newProductId = productIdMap[relation.productId]
                    
                    if (newPackageId != null && newProductId != null) {
                        packageRepository.addProductToPackage(newPackageId, newProductId)
                        restoredPackageRelations++
                    }
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore package relation", e)
                }
            }
            
            // Restore box-product relations
            backupData.boxProductRelations.forEach { relation ->
                try {
                    val newBoxId = boxIdMap[relation.boxId]
                    val newProductId = productIdMap[relation.productId]
                    
                    if (newBoxId != null && newProductId != null) {
                        boxRepository.addProductToBox(newBoxId, newProductId)
                        restoredBoxRelations++
                    }
                } catch (e: Exception) {
                    AppLogger.w("Restore", "Failed to restore box relation", e)
                }
            }
            
            // Delete the used backup
            backupRepository.deleteBackup(backup)
            
            val message = "Undo successful: Restored $restoredProducts products, $restoredPackages packages, $restoredBoxes boxes, $restoredContractors contractors, $restoredTemplates templates, $restoredPackageRelations pkg-relations, $restoredBoxRelations box-relations"
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
