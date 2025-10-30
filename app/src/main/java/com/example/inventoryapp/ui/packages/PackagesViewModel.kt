package com.example.inventoryapp.ui.packages

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class PackagesViewModel(
    private val packageRepository: PackageRepository,
    private val contractorRepository: ContractorRepository
) : ViewModel() {

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery

    private val allPackagesWithCount: StateFlow<List<PackageWithCount>> = 
        combine(
            packageRepository.getAllPackages(),
            contractorRepository.getAllContractors()
        ) { packages, contractors ->
            packages.map { pkg ->
                val contractor = pkg.contractorId?.let { contractorId ->
                    contractors.find { it.id == contractorId }
                }
                PackageWithCount(pkg, 0, contractor)
            }
        }.stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val packagesWithCount: StateFlow<List<PackageWithCount>> = combine(
        allPackagesWithCount,
        _searchQuery
    ) { packages, query ->
        if (query.isBlank()) {
            packages
        } else {
            packages.filter { packageWithCount ->
                packageWithCount.packageEntity.name.contains(query, ignoreCase = true) ||
                packageWithCount.packageEntity.status.contains(query, ignoreCase = true)
            }
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    fun setSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun createPackage(name: String, status: String = "PREPARATION") {
        viewModelScope.launch {
            val packageEntity = PackageEntity(
                name = name,
                status = status
            )
            packageRepository.insertPackage(packageEntity)
        }
    }

    fun deletePackage(packageEntity: PackageEntity) {
        viewModelScope.launch {
            packageRepository.deletePackage(packageEntity)
        }
    }
}

class PackagesViewModelFactory(
    private val packageRepository: PackageRepository,
    private val contractorRepository: ContractorRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(PackagesViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return PackagesViewModel(packageRepository, contractorRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
