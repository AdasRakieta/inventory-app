package com.example.inventoryapp.ui.products

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.ProductRepository
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class ProductDetailsViewModel(
    private val productRepository: ProductRepository,
    private val productId: Long
) : ViewModel() {

    private val _product = MutableStateFlow<ProductEntity?>(null)
    val product: StateFlow<ProductEntity?> = _product.asStateFlow()

    private val _snUpdateError = MutableStateFlow<String?>(null)
    val snUpdateError: StateFlow<String?> = _snUpdateError.asStateFlow()

    init {
        loadProduct()
    }

    private fun loadProduct() {
        viewModelScope.launch {
            productRepository.getProductById(productId).collect { productEntity ->
                _product.value = productEntity
            }
        }
    }

    fun updateSerialNumber(serialNumber: String) {
        viewModelScope.launch {
            val currentProduct = _product.value ?: return@launch
            
            // Check if SN already exists (and it's not our own product)
            val existingProduct = productRepository.getProductBySerialNumber(serialNumber)
            if (existingProduct != null && existingProduct.id != currentProduct.id) {
                _snUpdateError.value = "This Serial Number is already in use"
                return@launch
            }
            
            // Clear error and update
            _snUpdateError.value = null
            val updatedProduct = currentProduct.copy(
                serialNumber = serialNumber,
                updatedAt = System.currentTimeMillis()
            )
            productRepository.updateProduct(updatedProduct)
        }
    }

    fun clearSnError() {
        _snUpdateError.value = null
    }

    fun deleteProduct() {
        viewModelScope.launch {
            val currentProduct = _product.value ?: return@launch
            productRepository.deleteProduct(currentProduct)
        }
    }
}

class ProductDetailsViewModelFactory(
    private val productRepository: ProductRepository,
    private val productId: Long
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ProductDetailsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ProductDetailsViewModel(productRepository, productId) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
