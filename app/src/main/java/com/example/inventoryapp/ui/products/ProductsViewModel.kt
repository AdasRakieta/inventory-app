package com.example.inventoryapp.ui.products

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductEntity
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.PackageRepository
import com.example.inventoryapp.utils.AppLogger
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

enum class ProductSortOrder {
    NAME_ASC,
    NAME_DESC,
    DATE_NEWEST,
    DATE_OLDEST,
    CATEGORY
}

class ProductsViewModel(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository
) : ViewModel() {

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery
    
    private val _selectedCategoryId = MutableStateFlow<Long?>(null)
    val selectedCategoryId: StateFlow<Long?> = _selectedCategoryId
    
    private val _sortOrder = MutableStateFlow(ProductSortOrder.NAME_ASC)
    val sortOrder: StateFlow<ProductSortOrder> = _sortOrder

    private val allProducts: StateFlow<List<ProductWithPackage>> = productRepository.getAllProducts()
        .map { products ->
            products.map { product ->
                ProductWithPackage(product, null) // Initially without packages
            }
        }
        .flatMapLatest { products ->
            // For each product, combine with its package
            if (products.isEmpty()) {
                flowOf(emptyList())
            } else {
                val productFlows = products.map { productWithPackage ->
                    packageRepository.getPackageForProduct(productWithPackage.productEntity.id)
                        .map { pkg -> productWithPackage.copy(packageEntity = pkg) }
                }
                combine(productFlows) { it.toList() }
            }
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val products: StateFlow<List<ProductWithPackage>> = combine(
        allProducts,
        _searchQuery,
        _selectedCategoryId,
        _sortOrder
    ) { products, query, categoryId, sortOrder ->
        var filtered = products
        
        // Apply search filter
        if (query.isNotBlank()) {
            filtered = filtered.filter { productWithPackage ->
                val product = productWithPackage.productEntity
                product.name.contains(query, ignoreCase = true) ||
                product.serialNumber?.contains(query, ignoreCase = true) == true
            }
        }
        
        // Apply category filter
        if (categoryId != null) {
            filtered = filtered.filter { it.productEntity.categoryId == categoryId }
        }
        
        // Apply sorting
        when (sortOrder) {
            ProductSortOrder.NAME_ASC -> filtered.sortedBy { it.productEntity.name.toLowerCase() }
            ProductSortOrder.NAME_DESC -> filtered.sortedByDescending { it.productEntity.name.toLowerCase() }
            ProductSortOrder.DATE_NEWEST -> filtered.sortedByDescending { it.productEntity.createdAt }
            ProductSortOrder.DATE_OLDEST -> filtered.sortedBy { it.productEntity.createdAt }
            ProductSortOrder.CATEGORY -> filtered.sortedBy { it.productEntity.categoryId ?: Long.MAX_VALUE }
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    fun setSearchQuery(query: String) {
        _searchQuery.value = query
        viewModelScope.launch {
            AppLogger.logAction("Product Search", "Query: $query")
        }
    }
    
    fun setCategoryFilter(categoryId: Long?) {
        _selectedCategoryId.value = categoryId
        viewModelScope.launch {
            AppLogger.logAction("Product Category Filter", "Category ID: $categoryId")
        }
    }
    
    fun setSortOrder(sortOrder: ProductSortOrder) {
        _sortOrder.value = sortOrder
        viewModelScope.launch {
            AppLogger.logAction("Product Sort", "Sort Order: ${sortOrder.name}")
        }
    }

    fun addProduct(
        name: String,
        categoryId: Long? = null,
        serialNumber: String,
        description: String? = null
    ) {
        viewModelScope.launch {
            val product = ProductEntity(
                name = name,
                categoryId = categoryId,
                serialNumber = serialNumber
            )
            productRepository.insertProduct(product)
            AppLogger.logAction("Product Added", "Name: $name, SN: $serialNumber")
        }
    }

    fun deleteProduct(product: ProductEntity) {
        viewModelScope.launch {
            productRepository.deleteProduct(product)
            AppLogger.logAction("Product Deleted", "Name: ${product.name}")
        }
    }
    
    fun deleteProduct(productId: Long) {
        viewModelScope.launch {
            productRepository.deleteProductById(productId)
            AppLogger.logAction("Product Deleted", "ID: $productId")
        }
    }
}

class ProductsViewModelFactory(
    private val productRepository: ProductRepository,
    private val packageRepository: PackageRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ProductsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ProductsViewModel(productRepository, packageRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
