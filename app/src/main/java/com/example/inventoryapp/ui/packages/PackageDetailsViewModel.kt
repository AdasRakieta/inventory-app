package com.example.inventoryapp.ui.packages

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ContractorEntity
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.data.repository.ProductRepository
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class PackageDetailsViewModel(
    private val packageRepository: PackageRepository,
    private val productRepository: ProductRepository,
    private val contractorRepository: ContractorRepository,
    private val packageId: Long
) : ViewModel() {

    private val _packageEntity = MutableStateFlow<PackageEntity?>(null)
    val packageEntity: StateFlow<PackageEntity?> = _packageEntity.asStateFlow()

    private val _productsInPackage = MutableStateFlow<List<ProductEntity>>(emptyList())
    val productsInPackage: StateFlow<List<ProductEntity>> = _productsInPackage.asStateFlow()

    private val _contractor = MutableStateFlow<ContractorEntity?>(null)
    val contractor: StateFlow<ContractorEntity?> = _contractor.asStateFlow()

    init {
        loadPackage()
        loadProducts()
    }

    private fun loadPackage() {
        viewModelScope.launch {
            packageRepository.getPackageById(packageId).collect { pkg ->
                _packageEntity.value = pkg
                // Load contractor if package has one assigned
                pkg?.contractorId?.let { contractorId ->
                    loadContractorById(contractorId)
                } ?: run {
                    _contractor.value = null
                }
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

    private fun loadContractorById(contractorId: Long) {
        viewModelScope.launch {
            contractorRepository.getContractorById(contractorId).collect { contractor ->
                _contractor.value = contractor
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

    fun updatePackageContractor(contractorId: Long?) {
        viewModelScope.launch {
            val currentPackage = _packageEntity.value ?: return@launch
            val updatedPackage = currentPackage.copy(contractorId = contractorId)
            packageRepository.updatePackage(updatedPackage)
        }
    }

    fun addNewProductToPackage(serialNumber: String, categoryId: Long, productName: String? = null) {
        viewModelScope.launch {
            try {
                // Check if product with this serial number already exists
                val existingProduct = productRepository.getProductBySerialNumber(serialNumber)
                
                val productToAdd = if (existingProduct != null) {
                    // Use existing product
                    existingProduct
                } else {
                    // Create new product
                    val finalProductName = productName?.takeIf { it.isNotBlank() } ?: serialNumber
                    val newProduct = ProductEntity(
                        name = finalProductName,
                        categoryId = categoryId,
                        serialNumber = serialNumber
                    )
                    val productId = productRepository.insertProduct(newProduct)
                    newProduct.copy(id = productId)
                }
                
                // Add product to package
                packageRepository.addProductToPackage(packageId, productToAdd.id)
                
            } catch (e: Exception) {
                // Error will be handled in the fragment
                throw e
            }
        }
    }

    fun removeProductFromPackage(productId: Long) {
        viewModelScope.launch {
            try {
                packageRepository.removeProductFromPackage(packageId, productId)
            } catch (e: Exception) {
                // Error will be handled in the fragment
                throw e
            }
        }
    }

    fun updatePackageStatus(newStatus: String) {
        viewModelScope.launch {
            try {
                val currentPackage = _packageEntity.value ?: return@launch
                val updatedPackage = when (newStatus) {
                    "SHIPPED" -> currentPackage.copy(
                        status = newStatus,
                        shippedAt = System.currentTimeMillis()
                    )
                    "DELIVERED" -> currentPackage.copy(
                        status = newStatus,
                        deliveredAt = System.currentTimeMillis()
                    )
                    else -> currentPackage.copy(status = newStatus)
                }
                packageRepository.updatePackage(updatedPackage)
            } catch (e: Exception) {
                // Error will be handled in the fragment
                throw e
            }
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
    private val productRepository: ProductRepository,
    private val contractorRepository: ContractorRepository,
    private val packageId: Long
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(PackageDetailsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return PackageDetailsViewModel(packageRepository, productRepository, contractorRepository, packageId) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
