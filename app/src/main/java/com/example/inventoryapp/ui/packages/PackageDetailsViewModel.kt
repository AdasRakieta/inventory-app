package com.example.inventoryapp.ui.packages

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PackageDetailsViewModel(
    private val packageRepository: PackageRepository,
    private val packageId: Long
) : ViewModel() {

    private val _packageEntity = MutableStateFlow<PackageEntity?>(null)
    val packageEntity: StateFlow<PackageEntity?> = _packageEntity.asStateFlow()

    private val _productsInPackage = MutableStateFlow<List<ProductEntity>>(emptyList())
    val productsInPackage: StateFlow<List<ProductEntity>> = _productsInPackage.asStateFlow()

    init {
        loadPackage()
        loadProducts()
    }

    private fun loadPackage() {
        viewModelScope.launch {
            packageRepository.getPackageById(packageId).collect { pkg ->
                _packageEntity.value = pkg
            }
        }
    }

    private fun loadProducts() {
        viewModelScope.launch {
            packageRepository.getProductsInPackage(packageId).collect { products ->
                _productsInPackage.value = products
            }
        }
    }

    fun updatePackageName(name: String) {
        viewModelScope.launch {
            val currentPackage = _packageEntity.value ?: return@launch
            val updatedPackage = currentPackage.copy(name = name)
            packageRepository.updatePackage(updatedPackage)
        }
    }

    fun updatePackageStatus(status: String) {
        viewModelScope.launch {
            val currentPackage = _packageEntity.value ?: return@launch
            val updatedPackage = currentPackage.copy(
                status = status,
                shippedAt = if (status == "SHIPPED" && currentPackage.shippedAt == null) {
                    System.currentTimeMillis()
                } else {
                    currentPackage.shippedAt
                }
            )
            packageRepository.updatePackage(updatedPackage)
        }
    }

    fun removeProductFromPackage(productId: Long) {
        viewModelScope.launch {
            packageRepository.removeProductFromPackage(packageId, productId)
        }
    }

    fun deletePackage() {
        viewModelScope.launch {
            val currentPackage = _packageEntity.value ?: return@launch
            packageRepository.deletePackage(currentPackage)
        }
    }
}

class PackageDetailsViewModelFactory(
    private val packageRepository: PackageRepository,
    private val packageId: Long
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(PackageDetailsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return PackageDetailsViewModel(packageRepository, packageId) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
