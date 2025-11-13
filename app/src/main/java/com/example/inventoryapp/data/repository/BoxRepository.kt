package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.BoxDao
import com.example.inventoryapp.data.local.dao.PackageDao
import com.example.inventoryapp.data.local.entities.BoxEntity
import com.example.inventoryapp.data.local.dao.BoxWithCount
import com.example.inventoryapp.data.local.entities.ProductWithCategory
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.BoxProductCrossRef
import com.example.inventoryapp.data.models.AddProductResult
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first

class BoxRepository(
    private val boxDao: BoxDao, 
    private val productDao: com.example.inventoryapp.data.local.dao.ProductDao,
    private val packageDao: PackageDao
) {

    fun getAllBoxes(): Flow<List<BoxEntity>> = boxDao.getAllBoxes()

    fun getAllBoxesWithCount(): Flow<List<BoxWithCount>> = boxDao.getAllBoxesWithCount()

    fun getBoxById(boxId: Long): Flow<BoxEntity?> = boxDao.getBoxById(boxId)

    fun getProductsInBox(boxId: Long): Flow<List<ProductEntity>> = boxDao.getProductsInBox(boxId)
    
    fun getProductsWithCategoriesInBox(boxId: Long): Flow<List<ProductWithCategory>> = boxDao.getProductsWithCategoriesInBox(boxId)

    fun getProductCountInBox(boxId: Long): Flow<Int> = boxDao.getProductCountInBox(boxId)

    fun getBoxCount(): Flow<Int> = boxDao.getBoxCount()

    suspend fun insertBox(box: BoxEntity): Long {
        // Check if box with same name already exists
        val existing = boxDao.getBoxByName(box.name)
        if (existing != null) {
            throw IllegalArgumentException("Box with name '${box.name}' already exists")
        }
        return boxDao.insertBox(box)
    }

    suspend fun createBox(name: String, description: String?, warehouseLocation: String?): Long {
        val box = BoxEntity(
            name = name,
            description = description,
            warehouseLocation = warehouseLocation
        )
        return insertBox(box)
    }

    suspend fun updateBox(box: BoxEntity) = boxDao.updateBox(box)

    suspend fun deleteBox(box: BoxEntity) = boxDao.deleteBox(box)

    suspend fun deleteBox(boxId: Long) = boxDao.deleteBoxById(boxId)

    suspend fun deleteBoxById(boxId: Long) = boxDao.deleteBoxById(boxId)

    suspend fun addProductToBox(boxId: Long, productId: Long): AddProductResult {
        return try {
            // Check if product is already in a package (ignore archived packages)
            val existingPackage = packageDao.getPackageForProduct(productId).first()
            if (existingPackage != null && !existingPackage.archived) {
                // If package is not returned, prevent adding to box
                if (existingPackage.status != "RETURNED") {
                    return AddProductResult.AlreadyInActivePackage(existingPackage.name, existingPackage.status)
                } else {
                    // Package is returned (but not archived), remove from it and add transfer message
                    packageDao.removeProductFromPackage(PackageProductCrossRef(existingPackage.id, productId))
                    val crossRef = BoxProductCrossRef(boxId, productId)
                    boxDao.addProductToBox(crossRef)
                    return AddProductResult.TransferredFromPackage(existingPackage.name)
                }
            }

            // Product not in any non-archived package, just add it
            val crossRef = BoxProductCrossRef(boxId, productId)
            boxDao.addProductToBox(crossRef)
            AddProductResult.Success
        } catch (e: Exception) {
            AddProductResult.Error("Failed to add product to box: ${e.message}")
        }
    }

    suspend fun removeProductFromBox(boxId: Long, productId: Long) {
        boxDao.removeProductFromBoxById(boxId, productId)
    }
    
    suspend fun isProductInBox(boxId: Long, productId: Long): Boolean {
        return boxDao.isProductInBox(boxId, productId)
    }
    
    fun getBoxByProductId(productId: Long): Flow<BoxEntity?> {
        return boxDao.getBoxForProduct(productId)
    }
}
