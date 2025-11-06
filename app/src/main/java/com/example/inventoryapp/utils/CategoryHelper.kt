package com.example.inventoryapp.utils

/**
 * Helper class for managing product categories with icons
 */
object CategoryHelper {
    
    data class Category(
        val id: Long,
        val name: String,
        val icon: String,
        val requiresSerialNumber: Boolean = true
    )
    
    private val categories = listOf(
        Category(1L, "Scanner", "🔍", requiresSerialNumber = true),
        Category(2L, "Printer", "🖨️", requiresSerialNumber = true),
            Category(3L, "Scanner Docking Station", "🪫", requiresSerialNumber = true),
        Category(4L, "Printer Docking Station", "🔌", requiresSerialNumber = true),
        Category(5L, "Other", "📦", requiresSerialNumber = false)
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
    
    /**
     * Alias for getCategoryIdByName for consistency
     */
    fun getCategoryId(name: String): Long? = getCategoryIdByName(name)
    
    fun getCategoryNames(): List<String> {
        return categories.map { it.name }
    }
    
    /**
     * Check if category requires serial number
     * @param categoryId Category ID to check
     * @return true if serial number is required, false otherwise
     */
    fun requiresSerialNumber(categoryId: Long?): Boolean {
        return getCategoryById(categoryId)?.requiresSerialNumber ?: true // Default to required
    }
    
    /**
     * Check if category requires serial number by name
     * @param categoryName Category name to check
     * @return true if serial number is required, false otherwise
     */
    fun requiresSerialNumber(categoryName: String): Boolean {
        val categoryId = getCategoryIdByName(categoryName)
        return requiresSerialNumber(categoryId)
    }
}
