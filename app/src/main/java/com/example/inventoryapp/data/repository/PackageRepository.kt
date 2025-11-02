package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.PackageDao
import com.example.inventoryapp.data.local.dao.ProductDao
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.models.PackageExportData
import com.example.inventoryapp.data.models.PackageImportResult
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first

class PackageRepository(
    private val packageDao: PackageDao,
    private val productDao: ProductDao
) {
    
    fun getAllPackages(): Flow<List<PackageEntity>> = packageDao.getAllPackages()
    
    fun getPackageById(packageId: Long): Flow<PackageEntity?> = 
        packageDao.getPackageById(packageId)
    
    suspend fun insertPackage(packageEntity: PackageEntity): Long =
        packageDao.insertPackage(packageEntity)
    
    suspend fun updatePackage(packageEntity: PackageEntity) =
        packageDao.updatePackage(packageEntity)
    
    suspend fun deletePackage(packageEntity: PackageEntity) =
        packageDao.deletePackage(packageEntity)
    
    suspend fun deletePackageById(packageId: Long) =
        packageDao.deletePackageById(packageId)
    
    suspend fun addProductToPackage(packageId: Long, productId: Long) =
        packageDao.addProductToPackage(PackageProductCrossRef(packageId, productId))
    
    suspend fun removeProductFromPackage(packageId: Long, productId: Long) =
        packageDao.removeProductFromPackage(PackageProductCrossRef(packageId, productId))
    
    fun getProductsInPackage(packageId: Long): Flow<List<ProductEntity>> =
        packageDao.getProductsInPackage(packageId)
    
    fun getPackageForProduct(productId: Long): Flow<PackageEntity?> =
        packageDao.getPackageForProduct(productId)
    
    fun getPackageByProductId(productId: Long): Flow<PackageEntity?> =
        getPackageForProduct(productId)
    
    suspend fun removeAllProductsFromPackage(packageId: Long) =
        packageDao.removeAllProductsFromPackage(packageId)
    
    /**
     * Export package data for QR code sharing
     */
    suspend fun exportPackage(packageId: Long): PackageExportData? {
        val pkg = getPackageById(packageId).first() ?: return null
        val products = getProductsInPackage(packageId).first()
        return PackageExportData(
            packageInfo = pkg,
            products = products
        )
    }
    
    /**
     * Import package data from QR scan with merge logic:
     * - Keep existing products in database
     * - Add new products from import
     * - If serial numbers match, overwrite with imported data (update)
     */
    suspend fun importPackage(exportData: PackageExportData): PackageImportResult {
        val errors = mutableListOf<String>()
        var productsAdded = 0
        var productsUpdated = 0
        
        try {
            // Insert or update package
            val existingPkg = getPackageById(exportData.packageInfo.id).first()
            val packageId = if (existingPkg == null) {
                insertPackage(exportData.packageInfo)
            } else {
                updatePackage(exportData.packageInfo)
                exportData.packageInfo.id
            }
            
            // Process each product
            for (importedProduct in exportData.products) {
                try {
                    // Check if product with this serial number already exists
                    val existingProduct = if (importedProduct.serialNumber != null) {
                        productDao.getProductBySerialNumber(importedProduct.serialNumber)
                    } else {
                        null
                    }
                    
                    val productId = if (existingProduct != null) {
                        // Product with matching SN exists - update it
                        val updatedProduct = importedProduct.copy(
                            id = existingProduct.id,
                            updatedAt = System.currentTimeMillis()
                        )
                        productDao.updateProduct(updatedProduct)
                        productsUpdated++
                        existingProduct.id
                    } else {
                        // New product - insert it
                        val newProduct = importedProduct.copy(
                            id = 0, // Let database assign new ID
                            createdAt = System.currentTimeMillis(),
                            updatedAt = System.currentTimeMillis()
                        )
                        val newId = productDao.insertProduct(newProduct)
                        productsAdded++
                        newId
                    }
                    
                    // Add product to package (if not already there)
                    try {
                        addProductToPackage(packageId, productId)
                    } catch (e: Exception) {
                        // Ignore if already in package
                    }
                    
                } catch (e: Exception) {
                    errors.add("Error importing product ${importedProduct.name}: ${e.message}")
                }
            }
            
            return PackageImportResult(
                success = errors.isEmpty(),
                productsAdded = productsAdded,
                productsUpdated = productsUpdated,
                errors = errors
            )
            
        } catch (e: Exception) {
            return PackageImportResult(
                success = false,
                errors = listOf("Package import failed: ${e.message}")
            )
        }
    }
    
    suspend fun isProductInPackage(packageId: Long, productId: Long): Boolean {
        return packageDao.isProductInPackage(packageId, productId)
    }
}
