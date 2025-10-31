package com.example.inventoryapp.data.local.entity

import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity

/**
 * Data class for import preview showing what will be added/updated
 */
data class ImportPreview(
    val newProducts: List<ProductEntity>,
    val updateProducts: List<ProductEntity>,
    val newPackages: List<PackageEntity>,
    val updatePackages: List<PackageEntity>,
    val newTemplates: List<ProductTemplateEntity>
) {
    val totalNewItems: Int
        get() = newProducts.size + newPackages.size + newTemplates.size
    
    val totalUpdateItems: Int
        get() = updateProducts.size + updatePackages.size
    
    val totalItems: Int
        get() = totalNewItems + totalUpdateItems
    
    fun isEmpty(): Boolean = totalItems == 0
}

/**
 * Sealed class for filtering import preview items
 */
sealed class ImportPreviewFilter {
    object All : ImportPreviewFilter()
    object NewProducts : ImportPreviewFilter()
    object UpdateProducts : ImportPreviewFilter()
    object NewPackages : ImportPreviewFilter()
    object UpdatePackages : ImportPreviewFilter()
    object NewTemplates : ImportPreviewFilter()
}
