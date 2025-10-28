package com.example.inventoryapp.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Product template for inventory catalog.
 * Allows creating product definitions without serial numbers,
 * which can be used during bulk inventory scanning.
 */
@Entity(tableName = "product_templates")
data class ProductTemplateEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val categoryId: Long? = null,
    val description: String? = null,
    val imageUri: String? = null,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
