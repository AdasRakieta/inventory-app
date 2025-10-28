package com.example.inventoryapp.data.local.dao

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.PackageProductCrossRef
import com.example.inventoryapp.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PackageDao {
    @Query("SELECT * FROM packages ORDER BY createdAt DESC")
    fun getAllPackages(): Flow<List<PackageEntity>>

    @Query("SELECT * FROM packages WHERE id = :packageId")
    fun getPackageById(packageId: Long): Flow<PackageEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertPackage(packageEntity: PackageEntity): Long

    @Update
    suspend fun updatePackage(packageEntity: PackageEntity)

    @Delete
    suspend fun deletePackage(packageEntity: PackageEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun addProductToPackage(crossRef: PackageProductCrossRef)

    @Delete
    suspend fun removeProductFromPackage(crossRef: PackageProductCrossRef)

    @RewriteQueriesToDropUnusedColumns
    @Query("SELECT * FROM products INNER JOIN package_product_cross_ref ON products.id = package_product_cross_ref.productId WHERE package_product_cross_ref.packageId = :packageId")
    fun getProductsInPackage(packageId: Long): Flow<List<ProductEntity>>

    @Query("DELETE FROM package_product_cross_ref WHERE packageId = :packageId")
    suspend fun removeAllProductsFromPackage(packageId: Long)
}
