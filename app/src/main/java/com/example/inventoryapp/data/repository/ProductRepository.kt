package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.ProductDao
import com.example.inventoryapp.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

class ProductRepository(private val productDao: ProductDao) {
    
    fun getAllProducts(): Flow<List<ProductEntity>> = productDao.getAllProducts()
    
    fun getProductById(productId: Long): Flow<ProductEntity?> = productDao.getProductById(productId)
    
    suspend fun getProductBySerialNumber(serialNumber: String): ProductEntity? =
        productDao.getProductBySerialNumber(serialNumber)
    
    suspend fun insertProduct(product: ProductEntity): Long =
        productDao.insertProduct(product)
    
    suspend fun insertProducts(products: List<ProductEntity>) =
        productDao.insertProducts(products)
    
    suspend fun updateProduct(product: ProductEntity) =
        productDao.updateProduct(product)
    
    suspend fun deleteProduct(product: ProductEntity) =
        productDao.deleteProduct(product)
    
    suspend fun deleteProductBySerialNumber(serialNumber: String) =
        productDao.deleteProductBySerialNumber(serialNumber)
    
    suspend fun updateSerialNumber(productId: Long, serialNumber: String) =
        productDao.updateSerialNumber(productId, serialNumber, System.currentTimeMillis())
    
    suspend fun isSerialNumberExists(serialNumber: String): Boolean =
        productDao.isSerialNumberExists(serialNumber) > 0
}
