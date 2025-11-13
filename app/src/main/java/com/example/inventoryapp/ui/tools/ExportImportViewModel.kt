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
import com.example.inventoryapp.data.local.entity.ImportPreviewFilter
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

import com.example.inventoryapp.data.local.entities.InventoryCountSessionEntity
import com.example.inventoryapp.data.local.entities.InventoryCountItemEntity

/**
 * Enhanced export data structure with relationships
 */
data class ExportData(
    val version: Int = 4, // Incremented version for full backup (added inventory count)
    val exportedAt: Long = System.currentTimeMillis(),
    val products: List<ProductEntity>,
    val packages: List<PackageEntity>,
    val templates: List<ProductTemplateEntity>,
    val boxes: List<BoxEntity>,
    val contractors: List<ContractorEntity>,
    val packageProductRelations: List<PackageProductCrossRef> = emptyList(), // Product-Package relations
    val boxProductRelations: List<BoxProductCrossRef> = emptyList(), // Product-Box relations
    val inventoryCountSessions: List<InventoryCountSessionEntity> = emptyList(),
    val inventoryCountItems: List<InventoryCountItemEntity> = emptyList()
)

class ExportImportViewModel(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository,
    private val templateRepository: ProductTemplateRepository,
    private val backupRepository: ImportBackupRepository,
    private val boxRepository: BoxRepository,
    private val contractorRepository: ContractorRepository,
    private val inventoryCountRepository: com.example.inventoryapp.data.repository.InventoryCountRepository
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

            // Inventory Count Sessions & Items
            val inventoryCountSessions = inventoryCountRepository.getAllSessions().first()
            val inventoryCountItems = mutableListOf<InventoryCountItemEntity>()
            for (session in inventoryCountSessions) {
                val items = inventoryCountRepository.getItemsForSession(session.id)
                inventoryCountItems.addAll(items)
            }

            val exportData = ExportData(
                products = products,
                packages = packages,
                templates = templates,
                boxes = boxes,
                contractors = contractors,
                packageProductRelations = packageProductRelations,
                boxProductRelations = boxProductRelations,
                inventoryCountSessions = inventoryCountSessions,
                inventoryCountItems = inventoryCountItems
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
            val packages = packageRepository.getAllPackages().first()
            val boxes = boxRepository.getAllBoxes().first()
            val contractors = contractorRepository.getAllContractors().first()
            
            // Ensure parent directory exists
            outputFile.parentFile?.mkdirs()
            
            val baseFileName = outputFile.nameWithoutExtension
            val parentDir = outputFile.parentFile
            
            // Export Products CSV
            val productsFile = File(parentDir, "${baseFileName}_products.csv")
            exportProductsToCsv(productsFile, products)
            
            // Export Packages CSV
            val packagesFile = File(parentDir, "${baseFileName}_packages.csv")
            exportPackagesToCsv(packagesFile, packages, contractors)
            
            // Export Boxes CSV
            val boxesFile = File(parentDir, "${baseFileName}_boxes.csv")
            exportBoxesToCsv(boxesFile, boxes)
            
            // Export Package-Product Relations CSV
            val packageProductsFile = File(parentDir, "${baseFileName}_package_products.csv")
            exportPackageProductRelations(packageProductsFile)
            
            // Export Box-Product Relations CSV
            val boxProductsFile = File(parentDir, "${baseFileName}_box_products.csv")
            exportBoxProductRelations(boxProductsFile)
            
            val message = "CSV export successful: ${products.size} products, ${packages.size} packages, ${boxes.size} boxes (5 files created)"
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
    
    private suspend fun exportProductsToCsv(file: File, products: List<ProductEntity>) {
        FileWriter(file).use { writer ->
            // CSV Header
            writer.append("ID,Name,Category ID,Serial Number,Description,Quantity,Created At,Updated At\n")
            
            // CSV Data
            products.forEach { product ->
                writer.append("${product.id},")
                writer.append("\"${escapeCsv(product.name)}\",")
                writer.append("${product.categoryId ?: ""},")
                writer.append("\"${escapeCsv(product.serialNumber ?: "")}\",")
                writer.append("\"${escapeCsv(product.description ?: "")}\",")
                writer.append("${product.quantity},")
                writer.append("${product.createdAt},")
                writer.append("${product.updatedAt}\n")
            }
        }
    }
    
    private suspend fun exportPackagesToCsv(file: File, packages: List<PackageEntity>, contractors: List<ContractorEntity>) {
        FileWriter(file).use { writer ->
            // CSV Header
            writer.append("ID,Name,Contractor ID,Contractor Name,Status,Created At,Shipped At,Delivered At\n")
            
            // CSV Data
            packages.forEach { pkg ->
                val contractor = contractors.find { it.id == pkg.contractorId }
                writer.append("${pkg.id},")
                writer.append("\"${escapeCsv(pkg.name)}\",")
                writer.append("${pkg.contractorId ?: ""},")
                writer.append("\"${escapeCsv(contractor?.name ?: "")}\",")
                writer.append("\"${pkg.status}\",")
                writer.append("${pkg.createdAt},")
                writer.append("${pkg.shippedAt ?: ""},")
                writer.append("${pkg.deliveredAt ?: ""}\n")
            }
        }
    }
    
    private suspend fun exportBoxesToCsv(file: File, boxes: List<BoxEntity>) {
        FileWriter(file).use { writer ->
            // CSV Header
            writer.append("ID,Name,Description,Warehouse Location,Created At\n")
            
            // CSV Data
            boxes.forEach { box ->
                writer.append("${box.id},")
                writer.append("\"${escapeCsv(box.name)}\",")
                writer.append("\"${escapeCsv(box.description ?: "")}\",")
                writer.append("\"${escapeCsv(box.warehouseLocation ?: "")}\",")
                writer.append("${box.createdAt}\n")
            }
        }
    }
    
    private suspend fun exportPackageProductRelations(file: File) {
        FileWriter(file).use { writer ->
            // CSV Header
            writer.append("Package ID,Product ID\n")
            
            // Get all packages and their products
            val packages = packageRepository.getAllPackages().first()
            packages.forEach { pkg ->
                val products = packageRepository.getProductsInPackage(pkg.id).first()
                products.forEach { product ->
                    writer.append("${pkg.id},${product.id}\n")
                }
            }
        }
    }
    
    private suspend fun exportBoxProductRelations(file: File) {
        FileWriter(file).use { writer ->
            // CSV Header
            writer.append("Box ID,Product ID\n")
            
            // Get all boxes and their products
            val boxes = boxRepository.getAllBoxes().first()
            boxes.forEach { box ->
                val products = boxRepository.getProductsInBox(box.id).first()
                products.forEach { product ->
                    writer.append("${box.id},${product.id}\n")
                }
            }
        }
    }
    
    private fun escapeCsv(value: String): String {
        return value.replace("\"", "\"\"")
    }
    
    /**
     * Import from CSV files (supports 5 separate files)
     */
    suspend fun importFromCsv(baseFile: File): Boolean {
        return try {
            _status.value = "Importing from CSV files..."
            AppLogger.logAction("CSV Import Started", "Base file: ${baseFile.absolutePath}")
            
            val baseName = baseFile.nameWithoutExtension
            val parentDir = baseFile.parentFile ?: return false
            
            // Find all related CSV files
            val productsFile = File(parentDir, "${baseName}_products.csv")
            val packagesFile = File(parentDir, "${baseName}_packages.csv")
            val boxesFile = File(parentDir, "${baseName}_boxes.csv")
            val packageProductsFile = File(parentDir, "${baseName}_package_products.csv")
            val boxProductsFile = File(parentDir, "${baseName}_box_products.csv")
            
            // Import in order: Products -> Packages -> Boxes -> Relations
            var productsCount = 0
            var packagesCount = 0
            var boxesCount = 0
            var packageRelationsCount = 0
            var boxRelationsCount = 0
            
            // 1. Import Products
            if (productsFile.exists()) {
                productsCount = importProductsFromCsv(productsFile)
            }
            
            // 2. Import Packages
            if (packagesFile.exists()) {
                packagesCount = importPackagesFromCsv(packagesFile)
            }
            
            // 3. Import Boxes
            if (boxesFile.exists()) {
                boxesCount = importBoxesFromCsv(boxesFile)
            }
            
            // 4. Import Package-Product Relations
            if (packageProductsFile.exists()) {
                packageRelationsCount = importPackageProductRelations(packageProductsFile)
            }
            
            // 5. Import Box-Product Relations
            if (boxProductsFile.exists()) {
                boxRelationsCount = importBoxProductRelations(boxProductsFile)
            }
            
            val message = "CSV import successful: $productsCount products, $packagesCount packages, $boxesCount boxes, $packageRelationsCount pkg-relations, $boxRelationsCount box-relations"
            _status.value = message
            AppLogger.logAction("CSV Import Completed", message)
            true
        } catch (e: Exception) {
            val errorMsg = "CSV import failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("CSV Import", e)
            false
        }
    }
    
    private suspend fun importProductsFromCsv(file: File): Int {
        var count = 0
        FileReader(file).use { reader ->
            val lines = reader.readLines()
            if (lines.isEmpty()) return 0
            
            // Skip header
            lines.drop(1).forEach { line ->
                try {
                    val parts = parseCsvLine(line)
                    if (parts.size >= 8) {
                        val id = parts[0].toLongOrNull() ?: 0
                        val name = parts[1]
                        val categoryId = parts[2].toLongOrNull()
                        val serialNumber = parts[3].ifEmpty { null }
                        val description = parts[4].ifEmpty { null }
                        val quantity = parts[5].toIntOrNull() ?: 1
                        val createdAt = parts[6].toLongOrNull() ?: System.currentTimeMillis()
                        val updatedAt = parts[7].toLongOrNull() ?: System.currentTimeMillis()
                        
                        // Check if product exists by serial number
                        val existingProduct = if (serialNumber != null) {
                            productRepository.getProductBySerialNumber(serialNumber)
                        } else {
                            null
                        }
                        
                        if (existingProduct != null) {
                            // Update existing product
                            val updated = existingProduct.copy(
                                name = name,
                                categoryId = categoryId,
                                description = description,
                                quantity = quantity,
                                updatedAt = System.currentTimeMillis()
                            )
                            productRepository.updateProduct(updated)
                        } else {
                            // Insert new product
                            val product = ProductEntity(
                                id = 0, // Auto-generate
                                name = name,
                                categoryId = categoryId,
                                serialNumber = serialNumber,
                                description = description,
                                quantity = quantity,
                                imageUri = null,
                                createdAt = createdAt,
                                updatedAt = updatedAt
                            )
                            productRepository.insertProduct(product)
                        }
                        count++
                    }
                } catch (e: Exception) {
                    AppLogger.logError("Import Product Row", e)
                }
            }
        }
        return count
    }
    
    private suspend fun importPackagesFromCsv(file: File): Int {
        var count = 0
        FileReader(file).use { reader ->
            val lines = reader.readLines()
            if (lines.isEmpty()) return 0
            
            // Skip header
            lines.drop(1).forEach { line ->
                try {
                    val parts = parseCsvLine(line)
                    if (parts.size >= 8) {
                        val id = parts[0].toLongOrNull() ?: 0
                        val name = parts[1]
                        val contractorId = parts[2].toLongOrNull()
                        // parts[3] is contractor name (ignored, we use ID)
                        val status = parts[4].ifEmpty { "PREPARATION" }
                        val createdAt = parts[5].toLongOrNull() ?: System.currentTimeMillis()
                        val shippedAt = parts[6].toLongOrNull()
                        val deliveredAt = parts[7].toLongOrNull()
                        
                        // Check if package exists by ID
                        val existingPackage = packageRepository.getPackageById(id).first()
                        
                        if (existingPackage != null) {
                            // Update existing package
                            val updated = existingPackage.copy(
                                name = name,
                                contractorId = contractorId,
                                status = status,
                                shippedAt = shippedAt,
                                deliveredAt = deliveredAt
                            )
                            packageRepository.updatePackage(updated)
                        } else {
                            // Insert new package with specific ID
                            val pkg = PackageEntity(
                                id = id,
                                name = name,
                                contractorId = contractorId,
                                status = status,
                                createdAt = createdAt,
                                shippedAt = shippedAt,
                                deliveredAt = deliveredAt
                            )
                            packageRepository.insertPackage(pkg)
                        }
                        count++
                    }
                } catch (e: Exception) {
                    AppLogger.logError("Import Package Row", e)
                }
            }
        }
        return count
    }
    
    private suspend fun importBoxesFromCsv(file: File): Int {
        var count = 0
        FileReader(file).use { reader ->
            val lines = reader.readLines()
            if (lines.isEmpty()) return 0
            
            // Skip header
            lines.drop(1).forEach { line ->
                try {
                    val parts = parseCsvLine(line)
                    if (parts.size >= 5) {
                        val id = parts[0].toLongOrNull() ?: 0
                        val name = parts[1]
                        val description = parts[2].ifEmpty { null }
                        val warehouseLocation = parts[3].ifEmpty { null }
                        val createdAt = parts[4].toLongOrNull() ?: System.currentTimeMillis()
                        
                        // Check if box exists by ID
                        val existingBox = boxRepository.getBoxById(id).first()
                        
                        if (existingBox != null) {
                            // Update existing box
                            val updated = existingBox.copy(
                                name = name,
                                description = description,
                                warehouseLocation = warehouseLocation
                            )
                            boxRepository.updateBox(updated)
                        } else {
                            // Insert new box with specific ID
                            val box = BoxEntity(
                                id = id,
                                name = name,
                                description = description,
                                warehouseLocation = warehouseLocation,
                                createdAt = createdAt
                            )
                            boxRepository.insertBox(box)
                        }
                        count++
                    }
                } catch (e: Exception) {
                    AppLogger.logError("Import Box Row", e)
                }
            }
        }
        return count
    }
    
    private suspend fun importPackageProductRelations(file: File): Int {
        var count = 0
        FileReader(file).use { reader ->
            val lines = reader.readLines()
            if (lines.isEmpty()) return 0
            
            // Skip header
            lines.drop(1).forEach { line ->
                try {
                    val parts = line.split(",")
                    if (parts.size >= 2) {
                        val packageId = parts[0].trim().toLongOrNull() ?: return@forEach
                        val productId = parts[1].trim().toLongOrNull() ?: return@forEach
                        
                        // Verify package and product exist
                        val packageExists = packageRepository.getPackageById(packageId).first() != null
                        val productExists = productRepository.getProductById(productId).first() != null
                        
                        if (packageExists && productExists) {
                            // Add product to package (ignore if already exists)
                            try {
                                packageRepository.addProductToPackage(packageId, productId)
                                count++
                            } catch (e: Exception) {
                                // Relation might already exist
                            }
                        }
                    }
                } catch (e: Exception) {
                    AppLogger.logError("Import Package-Product Relation", e)
                }
            }
        }
        return count
    }
    
    private suspend fun importBoxProductRelations(file: File): Int {
        var count = 0
        FileReader(file).use { reader ->
            val lines = reader.readLines()
            if (lines.isEmpty()) return 0
            
            // Skip header
            lines.drop(1).forEach { line ->
                try {
                    val parts = line.split(",")
                    if (parts.size >= 2) {
                        val boxId = parts[0].trim().toLongOrNull() ?: return@forEach
                        val productId = parts[1].trim().toLongOrNull() ?: return@forEach
                        
                        // Verify box and product exist
                        val boxExists = boxRepository.getBoxById(boxId).first() != null
                        val productExists = productRepository.getProductById(productId).first() != null
                        
                        if (boxExists && productExists) {
                            // Add product to box (ignore if already exists)
                            try {
                                boxRepository.addProductToBox(boxId, productId)
                                count++
                            } catch (e: Exception) {
                                // Relation might already exist
                            }
                        }
                    }
                } catch (e: Exception) {
                    AppLogger.logError("Import Box-Product Relation", e)
                }
            }
        }
        return count
    }
    
    /**
     * Parse CSV line handling quoted fields with commas
     */
    private fun parseCsvLine(line: String): List<String> {
        val result = mutableListOf<String>()
        var current = StringBuilder()
        var inQuotes = false
        
        var i = 0
        while (i < line.length) {
            val char = line[i]
            
            when {
                char == '"' && (i + 1 < line.length && line[i + 1] == '"') -> {
                    // Escaped quote
                    current.append('"')
                    i++ // Skip next quote
                }
                char == '"' -> {
                    inQuotes = !inQuotes
                }
                char == ',' && !inQuotes -> {
                    result.add(current.toString().trim())
                    current = StringBuilder()
                }
                else -> {
                    current.append(char)
                }
            }
            i++
        }
        
        // Add last field
        result.add(current.toString().trim())
        
        return result
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
            val existingContractors = contractorRepository.getAllContractors().first()
            val existingBoxes = boxRepository.getAllBoxes().first()
            
            // Map existing items by their unique identifiers
            val existingProductSNs = existingProducts.map { it.serialNumber }.toSet()
            val existingPackageIds = existingPackages.map { it.id }.toSet()
            val existingContractorIds = existingContractors.map { it.id }.toSet()
            val existingBoxIds = existingBoxes.map { it.id }.toSet()
            
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
            
            // Categorize contractors: new vs update
            val newContractors = mutableListOf<ContractorEntity>()
            val updateContractors = mutableListOf<ContractorEntity>()
            
            exportData.contractors.forEach { contractor ->
                if (existingContractorIds.contains(contractor.id)) {
                    updateContractors.add(contractor)
                } else {
                    newContractors.add(contractor)
                }
            }
            
            // Categorize boxes: new vs update
            val newBoxes = mutableListOf<BoxEntity>()
            val updateBoxes = mutableListOf<BoxEntity>()
            
            exportData.boxes.forEach { box ->
                if (existingBoxIds.contains(box.id)) {
                    updateBoxes.add(box)
                } else {
                    newBoxes.add(box)
                }
            }
            
            // Templates are always new (they use auto-increment IDs)
            val newTemplates = exportData.templates
            
            val preview = ImportPreview(
                newProducts = newProducts,
                updateProducts = updateProducts,
                newPackages = newPackages,
                updatePackages = updatePackages,
                newTemplates = newTemplates,
                newContractors = newContractors,
                updateContractors = updateContractors,
                newBoxes = newBoxes,
                updateBoxes = updateBoxes
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
            var importedInventorySessions = 0
            var importedInventoryItems = 0
            val productIdMap = mutableMapOf<Long, Long>()
            // Step 8: Import Inventory Count Sessions (UPSERT by name)
            val sessionIdMap = mutableMapOf<Long, Long>()
            exportData.inventoryCountSessions.forEach { session ->
                try {
                    val oldId = session.id
                    val existingSessions = inventoryCountRepository.getAllSessions().first()
                    val existing = existingSessions.find { it.name.equals(session.name, ignoreCase = true) }
                    val newId = if (existing != null) {
                        inventoryCountRepository.updateSession(session.copy(id = existing.id))
                        existing.id
                    } else {
                        inventoryCountRepository.createSession(session.name, session.notes)
                    }
                    sessionIdMap[oldId] = newId
                    importedInventorySessions++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped inventory session: ${session.name}", e)
                }
            }

            // Step 9: Import Inventory Count Items (map sessionId and productId)
            exportData.inventoryCountItems.forEach { item ->
                try {
                    val newSessionId = sessionIdMap[item.sessionId]
                    val newProductId = productIdMap[item.productId]
                    if (newSessionId != null && newProductId != null) {
                        val newItem = item.copy(id = 0, sessionId = newSessionId, productId = newProductId)
                        inventoryCountRepository.inventoryCountDao.insertItem(newItem)
                        importedInventoryItems++
                    }
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped inventory item: session ${item.sessionId} product ${item.productId}", e)
                }
            }

            // Step 1: Import contractors first (no dependencies) - UPSERT by name
            val contractorIdMap = mutableMapOf<Long, Long>()
            exportData.contractors.forEach { contractor ->
                try {
                    val oldId = contractor.id
                    // Check if contractor with same name exists
                    val existingContractors = contractorRepository.getAllContractors().first()
                    val existing = existingContractors.find { it.name.equals(contractor.name, ignoreCase = true) }
                    
                    val newId = if (existing != null) {
                        // Update existing contractor
                        contractorRepository.updateContractor(contractor.copy(id = existing.id))
                        existing.id
                    } else {
                        // Insert new contractor
                        contractorRepository.insertContractor(contractor.copy(id = 0))
                    }
                    contractorIdMap[oldId] = newId
                    importedContractors++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped contractor: ${contractor.name}", e)
                }
            }

            // Step 2: Import templates (no dependencies) - UPSERT by name
            exportData.templates.forEach { template ->
                try {
                    // Check if template with same name exists
                    val existingTemplates = templateRepository.getAllTemplates().first()
                    val existing = existingTemplates.find { it.name.equals(template.name, ignoreCase = true) }
                    
                    if (existing != null) {
                        // Update existing template
                        templateRepository.updateTemplate(template.copy(id = existing.id))
                    } else {
                        // Insert new template
                        templateRepository.insertTemplate(template.copy(id = 0))
                    }
                    importedTemplates++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped template: ${template.name}", e)
                }
            }

            // productIdMap already declared above
            // Step 3: Import products and track ID mapping (old ID -> new ID) - UPSERT by serialNumber
            exportData.products.forEach { product ->
                try {
                    val oldId = product.id
                    // Check if product with same serial number exists
                    val existingProducts = productRepository.getAllProducts().first()
                    val existing = existingProducts.find { 
                        it.serialNumber != null && 
                        it.serialNumber.equals(product.serialNumber, ignoreCase = true) 
                    }
                    
                    val newId = if (existing != null) {
                        // Update existing product
                        productRepository.updateProduct(product.copy(id = existing.id))
                        existing.id
                    } else {
                        // Insert new product
                        productRepository.insertProduct(product.copy(id = 0))
                    }
                    productIdMap[oldId] = newId
                    importedProducts++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped product: ${product.name}", e)
                }
            }

            // Step 4: Import packages and track ID mapping (old ID -> new ID) - UPSERT by name
            val packageIdMap = mutableMapOf<Long, Long>()
            exportData.packages.forEach { pkg ->
                try {
                    val oldId = pkg.id
                    // Check if package with same name exists
                    val existingPackages = packageRepository.getAllPackages().first()
                    val existing = existingPackages.find { it.name.equals(pkg.name, ignoreCase = true) }
                    
                    // Remap contractor ID if exists
                    val newContractorId = pkg.contractorId?.let { contractorIdMap[it] }
                    
                    val newId = if (existing != null) {
                        // Update existing package
                        packageRepository.updatePackage(pkg.copy(id = existing.id, contractorId = newContractorId ?: existing.contractorId))
                        existing.id
                    } else {
                        // Insert new package
                        packageRepository.insertPackage(pkg.copy(id = 0, contractorId = newContractorId))
                    }
                    packageIdMap[oldId] = newId
                    importedPackages++
                } catch (e: Exception) {
                    AppLogger.w("Import", "Skipped package: ${pkg.name}", e)
                }
            }

            // Step 5: Import boxes and track ID mapping - UPSERT by name
            val boxIdMap = mutableMapOf<Long, Long>()
            exportData.boxes.forEach { box ->
                try {
                    val oldId = box.id
                    // Check if box with same name exists
                    val existingBoxes = boxRepository.getAllBoxes().first()
                    val existing = existingBoxes.find { it.name.equals(box.name, ignoreCase = true) }
                    
                    val newId = if (existing != null) {
                        // Update existing box
                        boxRepository.updateBox(box.copy(id = existing.id))
                        existing.id
                    } else {
                        // Insert new box
                        boxRepository.insertBox(box.copy(id = 0))
                    }
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
            val messageFull = "Import successful: $importedProducts products, $importedPackages packages, $importedBoxes boxes, $importedContractors contractors, $importedTemplates templates, $importedPackageRelations pkg-relations, $importedBoxRelations box-relations, $importedInventorySessions inventory sessions, $importedInventoryItems inventory items"
            _status.value = messageFull
            AppLogger.logAction("Import Completed", messageFull)
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
    
    /**
     * Import from unified CSV format (single file with all entities)
     * Converts to ExportData format for preview compatibility
     */
    suspend fun parseUnifiedCsvToExportData(file: File): ExportData? {
        return try {
            AppLogger.logAction("Parse Unified CSV", "File: ${file.absolutePath}")
            
            val csvRows = mutableListOf<com.example.inventoryapp.data.local.entity.CsvRow>()
            
            FileReader(file).use { reader ->
                val lines = reader.readLines()
                if (lines.size < 2) {
                    AppLogger.w("Parse CSV", "File has no data rows")
                    return null
                }
                
                // Skip header (line 0)
                lines.drop(1).forEach { line ->
                    if (line.isNotBlank()) {
                        val fields = parseCsvLine(line)
                        val row = com.example.inventoryapp.data.local.entity.CsvRow.fromCsvFields(fields)
                        if (row != null && row.isValid()) {
                            csvRows.add(row)
                        } else {
                            AppLogger.w("Parse CSV", "Invalid row: $line")
                        }
                    }
                }
            }
            
            if (csvRows.isEmpty()) {
                AppLogger.w("Parse CSV", "No valid rows found")
                return null
            }
            
            // Convert CSV rows to entities
            val contractors = mutableListOf<ContractorEntity>()
            val contractorNameToId = mutableMapOf<String, Long>()
            var contractorId = 1L
            
            val packages = mutableListOf<PackageEntity>()
            val packageNameToId = mutableMapOf<String, Long>()
            var packageId = 1L
            
            val boxes = mutableListOf<BoxEntity>()
            val boxNameToId = mutableMapOf<String, Long>()
            var boxId = 1L
            
            val products = mutableListOf<ProductEntity>()
            var productId = 1L
            
            val packageProductRelations = mutableListOf<PackageProductCrossRef>()
            val boxProductRelations = mutableListOf<BoxProductCrossRef>()
            
            // First pass: Create contractors, packages, boxes
            csvRows.forEach { row ->
                when (row.type) {
                    com.example.inventoryapp.data.local.entity.CsvRow.TYPE_CONTRACTOR -> {
                        val contractor = ContractorEntity(
                            id = contractorId++,
                            name = row.name,
                            description = row.description,
                            createdAt = row.createdDate?.toLongOrNull() ?: System.currentTimeMillis()
                        )
                        contractors.add(contractor)
                        contractorNameToId[row.name] = contractor.id
                    }
                    
                    com.example.inventoryapp.data.local.entity.CsvRow.TYPE_PACKAGE -> {
                        val contractorIdRef = row.contractorName?.let { contractorNameToId[it] }
                        val pkg = PackageEntity(
                            id = packageId++,
                            name = row.name,
                            contractorId = contractorIdRef,
                            status = row.status ?: "PREPARATION",
                            createdAt = row.createdDate?.toLongOrNull() ?: System.currentTimeMillis(),
                            shippedAt = row.shippedDate?.toLongOrNull(),
                            deliveredAt = row.deliveredDate?.toLongOrNull()
                        )
                        packages.add(pkg)
                        packageNameToId[row.name] = pkg.id
                    }
                    
                    com.example.inventoryapp.data.local.entity.CsvRow.TYPE_BOX -> {
                        val box = BoxEntity(
                            id = boxId++,
                            name = row.name,
                            description = row.description,
                            warehouseLocation = row.location,
                            createdAt = row.createdDate?.toLongOrNull() ?: System.currentTimeMillis()
                        )
                        boxes.add(box)
                        boxNameToId[row.name] = box.id
                    }
                }
            }
            
            // Second pass: Create products with relationships
            csvRows.forEach { row ->
                if (row.type == com.example.inventoryapp.data.local.entity.CsvRow.TYPE_PRODUCT) {
                    // Map category name to ID
                    val categoryId = row.category?.let { categoryName ->
                        com.example.inventoryapp.utils.CategoryHelper.getCategoryId(categoryName)
                    }
                    
                    val product = ProductEntity(
                        id = productId,
                        name = row.name,
                        categoryId = categoryId,
                        serialNumber = row.serialNumber,
                        description = row.description,
                        quantity = row.quantity ?: 1,
                        imageUri = null,
                        createdAt = row.createdDate?.toLongOrNull() ?: System.currentTimeMillis(),
                        updatedAt = System.currentTimeMillis()
                    )
                    products.add(product)
                    
                    // Create relationships
                    row.packageName?.let { pkgName ->
                        packageNameToId[pkgName]?.let { pkgId ->
                            packageProductRelations.add(
                                PackageProductCrossRef(
                                    packageId = pkgId,
                                    productId = productId
                                )
                            )
                        }
                    }
                    
                    row.boxName?.let { boxName ->
                        boxNameToId[boxName]?.let { bxId ->
                            boxProductRelations.add(
                                BoxProductCrossRef(
                                    boxId = bxId,
                                    productId = productId
                                )
                            )
                        }
                    }
                    
                    productId++
                }
            }
            
            AppLogger.d("Parse CSV", "Parsed: ${contractors.size}C, ${packages.size}Pk, ${boxes.size}B, ${products.size}P")
            
            ExportData(
                version = 3,
                exportedAt = System.currentTimeMillis(),
                products = products,
                packages = packages,
                templates = emptyList(), // CSV doesn't support templates yet
                boxes = boxes,
                contractors = contractors,
                packageProductRelations = packageProductRelations,
                boxProductRelations = boxProductRelations
            )
        } catch (e: Exception) {
            AppLogger.logError("Parse Unified CSV", e)
            null
        }
    }
    
    /**
     * Import from unified CSV with actual database insertion
     */
    suspend fun importFromUnifiedCsv(file: File): Boolean {
        return try {
            _status.value = "Importing from unified CSV..."
            AppLogger.logAction("Unified CSV Import Started", "File: ${file.absolutePath}")
            
            // Parse CSV to ExportData
            val exportData = parseUnifiedCsvToExportData(file)
            if (exportData == null) {
                _status.value = "Failed to parse CSV file"
                return false
            }
            
            // Use existing JSON import logic
            val tempJsonFile = File(file.parentFile, "temp_import_${System.currentTimeMillis()}.json")
            try {
                FileWriter(tempJsonFile).use { writer ->
                    gson.toJson(exportData, writer)
                }
                
                val success = importFromJson(tempJsonFile)
                tempJsonFile.delete()
                
                if (success) {
                    _status.value = "CSV import successful: ${exportData.products.size} products, ${exportData.packages.size} packages, ${exportData.boxes.size} boxes"
                }
                
                success
            } finally {
                if (tempJsonFile.exists()) {
                    tempJsonFile.delete()
                }
            }
        } catch (e: Exception) {
            val errorMsg = "CSV import failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Unified CSV Import", e)
            false
        }
    }
    
    /**
     * Export to unified CSV format (single file with all entities)
     * Uses human-readable names for relationships instead of IDs
     */
    suspend fun exportToUnifiedCsv(outputFile: File): Boolean {
        return try {
            AppLogger.logAction("Unified CSV Export Started", "File: ${outputFile.absolutePath}")
            _status.value = "Exporting to unified CSV..."
            
            val products = productRepository.getAllProducts().first()
            val packages = packageRepository.getAllPackages().first()
            val boxes = boxRepository.getAllBoxes().first()
            val contractors = contractorRepository.getAllContractors().first()
            
            // Create lookup maps for names
            val packageIdToName = packages.associate { it.id to it.name }
            val boxIdToName = boxes.associate { it.id to it.name }
            val contractorIdToName = contractors.associate { it.id to it.name }
            
            // Get relationships
            val packageProductMap = mutableMapOf<Long, MutableList<Long>>() // productId -> packageIds
            packages.forEach { pkg ->
                val productsInPackage = packageRepository.getProductsInPackage(pkg.id).first()
                productsInPackage.forEach { product ->
                    packageProductMap.getOrPut(product.id) { mutableListOf() }.add(pkg.id)
                }
            }
            
            val boxProductMap = mutableMapOf<Long, MutableList<Long>>() // productId -> boxIds
            boxes.forEach { box ->
                val productsInBox = boxRepository.getProductsInBox(box.id).first()
                productsInBox.forEach { product ->
                    boxProductMap.getOrPut(product.id) { mutableListOf() }.add(box.id)
                }
            }
            
            FileWriter(outputFile).use { writer ->
                // Write header
                writer.append(com.example.inventoryapp.data.local.entity.CsvRow.CSV_HEADERS.joinToString(","))
                writer.append("\n")
                
                // Write contractors first (packages may reference them)
                contractors.forEach { contractor ->
                    val row = com.example.inventoryapp.data.local.entity.CsvRow(
                        type = com.example.inventoryapp.data.local.entity.CsvRow.TYPE_CONTRACTOR,
                        serialNumber = null,
                        name = contractor.name,
                        description = contractor.description,
                        category = null,
                        quantity = null,
                        packageName = null,
                        boxName = null,
                        contractorName = null,
                        location = null,
                        status = null,
                        createdDate = contractor.createdAt?.toString(),
                        shippedDate = null,
                        deliveredDate = null
                    )
                    writer.append(com.example.inventoryapp.data.local.entity.CsvRow.toCsvLine(row))
                    writer.append("\n")
                }
                
                // Write packages (with contractor names)
                packages.forEach { pkg ->
                    val contractorName = pkg.contractorId?.let { contractorIdToName[it] }
                    val row = com.example.inventoryapp.data.local.entity.CsvRow(
                        type = com.example.inventoryapp.data.local.entity.CsvRow.TYPE_PACKAGE,
                        serialNumber = null,
                        name = pkg.name,
                        description = null,
                        category = null,
                        quantity = null,
                        packageName = null,
                        boxName = null,
                        contractorName = contractorName,
                        location = null,
                        status = pkg.status,
                        createdDate = pkg.createdAt?.toString(),
                        shippedDate = pkg.shippedAt?.toString(),
                        deliveredDate = pkg.deliveredAt?.toString()
                    )
                    writer.append(com.example.inventoryapp.data.local.entity.CsvRow.toCsvLine(row))
                    writer.append("\n")
                }
                
                // Write boxes
                boxes.forEach { box ->
                    val row = com.example.inventoryapp.data.local.entity.CsvRow(
                        type = com.example.inventoryapp.data.local.entity.CsvRow.TYPE_BOX,
                        serialNumber = null,
                        name = box.name,
                        description = box.description,
                        category = null,
                        quantity = null,
                        packageName = null,
                        boxName = null,
                        contractorName = null,
                        location = box.location,
                        status = null,
                        createdDate = box.createdAt?.toString(),
                        shippedDate = null,
                        deliveredDate = null
                    )
                    writer.append(com.example.inventoryapp.data.local.entity.CsvRow.toCsvLine(row))
                    writer.append("\n")
                }
                
                // Write products (with package and box names)
                products.forEach { product ->
                    val packageIds = packageProductMap[product.id] ?: emptyList()
                    val boxIds = boxProductMap[product.id] ?: emptyList()
                    
                    // For simplicity, use first package/box if multiple
                    // TODO: Export multiple rows if product is in multiple packages/boxes
                    val packageName = packageIds.firstOrNull()?.let { packageIdToName[it] }
                    val boxName = boxIds.firstOrNull()?.let { boxIdToName[it] }
                    
                    val row = com.example.inventoryapp.data.local.entity.CsvRow(
                        type = com.example.inventoryapp.data.local.entity.CsvRow.TYPE_PRODUCT,
                        serialNumber = product.serialNumber,
                        name = product.name,
                        description = product.description,
                        category = com.example.inventoryapp.utils.CategoryHelper.getCategoryName(product.categoryId),
                        quantity = product.quantity,
                        packageName = packageName,
                        boxName = boxName,
                        contractorName = null,
                        location = null,
                        status = null,
                        createdDate = product.createdAt?.toString(),
                        shippedDate = null,
                        deliveredDate = null
                    )
                    writer.append(com.example.inventoryapp.data.local.entity.CsvRow.toCsvLine(row))
                    writer.append("\n")
                }
            }
            
            _status.value = "Export successful: ${contractors.size} contractors, ${packages.size} packages, ${boxes.size} boxes, ${products.size} products"
            AppLogger.logAction("Unified CSV Export", "Success: ${products.size}P, ${packages.size}Pk, ${boxes.size}B, ${contractors.size}C")
            
            true
        } catch (e: Exception) {
            val errorMsg = "Export failed: ${e.message}"
            _status.value = errorMsg
            AppLogger.logError("Unified CSV Export", e)
            false
        }
    }
}
