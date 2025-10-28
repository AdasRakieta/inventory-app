package com.example.inventoryapp.ui.packages

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.PackageEntity
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class PackagesViewModel(
    private val packageRepository: PackageRepository
) : ViewModel() {

    val packagesWithCount: StateFlow<List<PackageWithCount>> = 
        packageRepository.getAllPackages()
            .map { packages ->
                packages.map { pkg ->
                    // Product counts shown in package details screen
                    // Keeping it simple in list view for performance
                    PackageWithCount(pkg, 0)
                }
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5000),
                initialValue = emptyList()
            )

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
    private val packageRepository: PackageRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(PackagesViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return PackagesViewModel(packageRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
