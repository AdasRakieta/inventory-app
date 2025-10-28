package com.example.inventoryapp.ui.packages

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductRepository
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class ProductSelectionViewModel(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository,
    private val packageId: Long
) : ViewModel() {

    private val _availableProducts = MutableStateFlow<List<ProductEntity>>(emptyList())
    val availableProducts: StateFlow<List<ProductEntity>> = _availableProducts.asStateFlow()

    init {
        loadAvailableProducts()
    }

    private fun loadAvailableProducts() {
        viewModelScope.launch {
            // Get all products
            productRepository.getAllProducts().collect { allProducts ->
                // Get products already in package
                packageRepository.getProductsInPackage(packageId).collect { productsInPackage ->
                    val productsInPackageIds = productsInPackage.map { it.id }.toSet()
                    // Filter out products already in package
                    _availableProducts.value = allProducts.filter { 
                        it.id !in productsInPackageIds 
                    }
                }
            }
        }
    }

    suspend fun addProductsToPackage(productIds: Set<Long>) {
        productIds.forEach { productId ->
            packageRepository.addProductToPackage(packageId, productId)
        }
    }
}

class ProductSelectionViewModelFactory(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository,
    private val packageId: Long
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ProductSelectionViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ProductSelectionViewModel(productRepository, packageRepository, packageId) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
