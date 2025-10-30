package com.example.inventoryapp.utils

/**
 * Helper class for managing product categories with icons
 */
object CategoryHelper {
    
    data class Category(
        val id: Long,
        val name: String,
        val icon: String
    )
    
    private val categories = listOf(
        Category(1L, "Scanner", "🔍"),
        Category(2L, "Printer", "🖨️"),
        Category(3L, "Scanner Docking Station", "🔌"),
        Category(4L, "Printer Docking Station", "🔌")
    )
    
    fun getAllCategories(): List<Category> = categories
    
    fun getCategoryById(id: Long?): Category? {
        return categories.find { it.id == id }
    }
    
    fun getCategoryName(id: Long?): String {
        return getCategoryById(id)?.name ?: "Uncategorized"
    }
    
    fun getCategoryIcon(id: Long?): String {
        return getCategoryById(id)?.icon ?: "📦"
    }
    
    fun getCategoryIdByName(name: String): Long? {
        return categories.find { it.name.equals(name, ignoreCase = true) }?.id
    }
    
    fun getCategoryNames(): List<String> {
        return categories.map { it.name }
    }
}
