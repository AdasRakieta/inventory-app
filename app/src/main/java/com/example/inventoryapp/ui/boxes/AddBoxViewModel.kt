package com.example.inventoryapp.ui.boxes

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.BoxRepository
import com.example.inventoryapp.data.repository.ProductRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * ViewModel for creating a new box.
 * Handles product selection and box creation.
 */
class AddBoxViewModel(
    private val boxRepository: BoxRepository,
    private val productRepository: ProductRepository
) : ViewModel() {

    // All available products
    private val _allProducts = MutableStateFlow<List<ProductEntity>>(emptyList())
    val allProducts: StateFlow<List<ProductEntity>> = _allProducts.asStateFlow()

    // Selected product IDs
    private val _selectedProductIds = MutableStateFlow<Set<Long>>(emptySet())
    val selectedProductIds: StateFlow<Set<Long>> = _selectedProductIds.asStateFlow()

    // Box name input
    private val _boxName = MutableStateFlow("")
    val boxName: StateFlow<String> = _boxName.asStateFlow()

    // Box description input
    private val _boxDescription = MutableStateFlow("")
    val boxDescription: StateFlow<String> = _boxDescription.asStateFlow()

    // Warehouse location input
    private val _warehouseLocation = MutableStateFlow("")
    val warehouseLocation: StateFlow<String> = _warehouseLocation.asStateFlow()

    // Error message
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    // Success flag (box created)
    private val _boxCreated = MutableStateFlow(false)
    val boxCreated: StateFlow<Boolean> = _boxCreated.asStateFlow()

    init {
        loadProducts()
    }

    /**
     * Load all products from database
     */
    private fun loadProducts() {
        viewModelScope.launch {
            productRepository.getAllProducts().collect { products ->
                _allProducts.value = products
            }
        }
    }

    /**
     * Toggle product selection
     */
    fun toggleProductSelection(productId: Long) {
        val currentSelection = _selectedProductIds.value.toMutableSet()
        if (currentSelection.contains(productId)) {
            currentSelection.remove(productId)
        } else {
            currentSelection.add(productId)
        }
        _selectedProductIds.value = currentSelection
    }

    /**
     * Update box name
     */
    fun setBoxName(name: String) {
        _boxName.value = name
    }

    /**
     * Update box description
     */
    fun setBoxDescription(description: String) {
        _boxDescription.value = description
    }

    /**
     * Update warehouse location
     */
    fun setWarehouseLocation(location: String) {
        _warehouseLocation.value = location
    }

    /**
     * Create box with selected products
     */
    fun createBox() {
        viewModelScope.launch {
            try {
                // Validate inputs
                if (_boxName.value.isBlank()) {
                    _errorMessage.value = "Box name is required"
                    return@launch
                }

                if (_selectedProductIds.value.isEmpty()) {
                    _errorMessage.value = "Please select at least one product"
                    return@launch
                }

                // Create box
                val boxId = boxRepository.createBox(
                    name = _boxName.value,
                    description = _boxDescription.value.takeIf { it.isNotBlank() },
                    warehouseLocation = _warehouseLocation.value.takeIf { it.isNotBlank() }
                )

                // Add products to box
                _selectedProductIds.value.forEach { productId ->
                    boxRepository.addProductToBox(boxId, productId)
                }

                // Set success flag
                _boxCreated.value = true

            } catch (e: Exception) {
                _errorMessage.value = "Failed to create box: ${e.message}"
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
     * Select all products
     */
    fun selectAll() {
        _selectedProductIds.value = _allProducts.value.map { it.id }.toSet()
    }

    /**
     * Deselect all products
     */
    fun deselectAll() {
        _selectedProductIds.value = emptySet()
    }
}

/**
 * Factory for creating AddBoxViewModel with dependencies
 */
class AddBoxViewModelFactory(
    private val boxRepository: BoxRepository,
    private val productRepository: ProductRepository
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(AddBoxViewModel::class.java)) {
            return AddBoxViewModel(boxRepository, productRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
