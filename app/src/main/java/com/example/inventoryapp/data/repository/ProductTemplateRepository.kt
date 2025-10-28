package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.ProductTemplateDao
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import kotlinx.coroutines.flow.Flow

class ProductTemplateRepository(private val dao: ProductTemplateDao) {
    fun getAllTemplates(): Flow<List<ProductTemplateEntity>> = dao.getAllTemplates()

    suspend fun addTemplate(name: String, categoryId: Long? = null): Long {
        val now = System.currentTimeMillis()
        val tpl = ProductTemplateEntity(
            name = name,
            categoryId = categoryId,
            createdAt = now,
            updatedAt = now
        )
        return dao.insertTemplate(tpl)
    }

    suspend fun deleteTemplate(entity: ProductTemplateEntity) = dao.deleteTemplate(entity)
}
