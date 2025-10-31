package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.BoxDao
import com.example.inventoryapp.data.local.dao.BoxWithCount
import com.example.inventoryapp.data.local.entities.BoxEntity
import com.example.inventoryapp.data.local.entities.BoxProductCrossRef
import com.example.inventoryapp.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

class BoxRepository(private val boxDao: BoxDao) {

    fun getAllBoxes(): Flow<List<BoxEntity>> = boxDao.getAllBoxes()

    fun getAllBoxesWithCount(): Flow<List<BoxWithCount>> = boxDao.getAllBoxesWithCount()

    fun getBoxById(boxId: Long): Flow<BoxEntity?> = boxDao.getBoxById(boxId)

    fun getProductsInBox(boxId: Long): Flow<List<ProductEntity>> = boxDao.getProductsInBox(boxId)

    fun getProductCountInBox(boxId: Long): Flow<Int> = boxDao.getProductCountInBox(boxId)

    fun getBoxCount(): Flow<Int> = boxDao.getBoxCount()

    suspend fun insertBox(box: BoxEntity): Long = boxDao.insertBox(box)

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

    suspend fun addProductToBox(boxId: Long, productId: Long) {
        val crossRef = BoxProductCrossRef(boxId, productId)
        boxDao.addProductToBox(crossRef)
    }

    suspend fun removeProductFromBox(boxId: Long, productId: Long) {
        boxDao.removeProductFromBoxById(boxId, productId)
    }
}
