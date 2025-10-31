package com.example.inventoryapp.ui.boxes

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.BoxEntity
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.BoxRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * ViewModel for managing box details screen.
 * Handles displaying box info and its products.
 */
class BoxDetailsViewModel(
    private val boxRepository: BoxRepository,
    private val boxId: Long
) : ViewModel() {

    // Current box entity
    private val _box = MutableStateFlow<BoxEntity?>(null)
    val box: StateFlow<BoxEntity?> = _box.asStateFlow()

    // Products in this box
    private val _productsInBox = MutableStateFlow<List<ProductEntity>>(emptyList())
    val productsInBox: StateFlow<List<ProductEntity>> = _productsInBox.asStateFlow()

    // Error message
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        loadBox()
        loadProducts()
    }

    /**
     * Load box details from database
     */
    private fun loadBox() {
        viewModelScope.launch {
            boxRepository.getBoxById(boxId).collect { boxEntity ->
                _box.value = boxEntity
            }
        }
    }

    /**
     * Load products in this box
     */
    private fun loadProducts() {
        viewModelScope.launch {
            boxRepository.getProductsInBox(boxId).collect { products ->
                _productsInBox.value = products
            }
        }
    }

    /**
     * Remove a product from the box
     */
    fun removeProductFromBox(productId: Long) {
        viewModelScope.launch {
            try {
                boxRepository.removeProductFromBox(boxId, productId)
                // No need to manually reload - Flow will update
            } catch (e: Exception) {
                _errorMessage.value = "Failed to remove product: ${e.message}"
            }
        }
    }

    /**
     * Clear error message
     */
    fun clearError() {
        _errorMessage.value = null
    }

    /**
     * Delete the entire box
     */
    fun deleteBox() {
        viewModelScope.launch {
            try {
                boxRepository.deleteBox(boxId)
            } catch (e: Exception) {
                _errorMessage.value = "Failed to delete box: ${e.message}"
            }
        }
    }
}

/**
 * Factory for creating BoxDetailsViewModel with dependencies
 */
class BoxDetailsViewModelFactory(
    private val boxRepository: BoxRepository,
    private val boxId: Long
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(BoxDetailsViewModel::class.java)) {
            return BoxDetailsViewModel(boxRepository, boxId) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
