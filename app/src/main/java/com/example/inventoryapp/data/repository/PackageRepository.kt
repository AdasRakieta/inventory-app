package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.PackageDao
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

class PackageRepository(private val packageDao: PackageDao) {
    
    fun getAllPackages(): Flow<List<PackageEntity>> = packageDao.getAllPackages()
    
    fun getPackageById(packageId: Long): Flow<PackageEntity?> = 
        packageDao.getPackageById(packageId)
    
    suspend fun insertPackage(packageEntity: PackageEntity): Long =
        packageDao.insertPackage(packageEntity)
    
    suspend fun updatePackage(packageEntity: PackageEntity) =
        packageDao.updatePackage(packageEntity)
    
    suspend fun deletePackage(packageEntity: PackageEntity) =
        packageDao.deletePackage(packageEntity)
    
    suspend fun addProductToPackage(packageId: Long, productId: Long) =
        packageDao.addProductToPackage(PackageProductCrossRef(packageId, productId))
    
    suspend fun removeProductFromPackage(packageId: Long, productId: Long) =
        packageDao.removeProductFromPackage(PackageProductCrossRef(packageId, productId))
    
    fun getProductsInPackage(packageId: Long): Flow<List<ProductEntity>> =
        packageDao.getProductsInPackage(packageId)
    
    suspend fun removeAllProductsFromPackage(packageId: Long) =
        packageDao.removeAllProductsFromPackage(packageId)
}
