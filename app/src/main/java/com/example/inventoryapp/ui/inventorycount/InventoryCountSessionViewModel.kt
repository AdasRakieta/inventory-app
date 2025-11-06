package com.example.inventoryapp.ui.inventorycount

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.InventoryCountSessionEntity
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.InventoryCountRepository
import com.example.inventoryapp.data.repository.ScanResult
import com.example.inventoryapp.utils.CategoryHelper
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

/**
 * ViewModel for Inventory Count session details.
 * Manages product scanning, statistics, and session completion.
 */
class InventoryCountSessionViewModel(
    private val inventoryCountRepository: InventoryCountRepository,
    private val sessionId: Long
) : ViewModel() {

    // Current session
    private val _session = MutableStateFlow<InventoryCountSessionEntity?>(null)
    val session: StateFlow<InventoryCountSessionEntity?> = _session.asStateFlow()

    // Scanned products in this session
    private val _scannedProducts = MutableStateFlow<List<ProductEntity>>(emptyList())
    val scannedProducts: StateFlow<List<ProductEntity>> = _scannedProducts.asStateFlow()

    // Total count of scanned items
    val totalCount: StateFlow<Int> = _scannedProducts.map { it.size }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = 0
        )

    // Category statistics (category name -> count)
    val categoryStatistics: StateFlow<Map<String, Int>> = 
        inventoryCountRepository.getCategoryStatistics(sessionId)
            .map { categoryIdMap ->
                // Convert categoryId -> count to categoryName -> count
                categoryIdMap.mapKeys { (categoryId, _) ->
                    CategoryHelper.getCategoryById(categoryId)?.name ?: "Unknown"
                }
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = emptyMap()
            )

    // Last scan result
    private val _lastScanResult = MutableStateFlow<ScanResult?>(null)
    val lastScanResult: StateFlow<ScanResult?> = _lastScanResult.asStateFlow()

    init {
        loadSession()
        loadProducts()
    }

    private fun loadSession() {
        viewModelScope.launch {
            inventoryCountRepository.getSessionById(sessionId).collect { session ->
                _session.value = session
            }
        }
    }

    private fun loadProducts() {
        viewModelScope.launch {
            inventoryCountRepository.getProductsInSession(sessionId).collect { products ->
                _scannedProducts.value = products
            }
        }
    }

    /**
     * Scan a product by serial number.
     * Validates if product exists in database before adding to session.
     */
    suspend fun scanProduct(serialNumber: String): ScanResult {
        val result = inventoryCountRepository.scanProduct(sessionId, serialNumber)
        _lastScanResult.value = result
        return result
    }

    /**
     * Complete the session (mark as COMPLETED).
     */
    fun completeSession() {
        viewModelScope.launch {
            inventoryCountRepository.completeSession(sessionId)
        }
    }

    /**
     * Clear all scanned products from session.
     */
    fun clearSession() {
        viewModelScope.launch {
            inventoryCountRepository.clearSession(sessionId)
        }
    }

    /**
     * Clear last scan result message.
     */
    fun clearScanResult() {
        _lastScanResult.value = null
    }

    /**
     * Get detailed category statistics for dialog display.
     */
    suspend fun getDetailedStatistics(): List<InventoryCountStatistic> {
        val categoryMap = inventoryCountRepository.getCategoryStatistics(sessionId).first()
        
        return categoryMap.map { (categoryId, count) ->
            val category = CategoryHelper.getCategoryById(categoryId)
            InventoryCountStatistic(
                categoryId = categoryId,
                categoryName = category?.name ?: "Unknown",
                categoryIcon = category?.icon ?: "📦",
                count = count
            )
        }.sortedByDescending { it.count }
    }
}

class InventoryCountSessionViewModelFactory(
    private val inventoryCountRepository: InventoryCountRepository,
    private val sessionId: Long
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(InventoryCountSessionViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return InventoryCountSessionViewModel(inventoryCountRepository, sessionId) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
