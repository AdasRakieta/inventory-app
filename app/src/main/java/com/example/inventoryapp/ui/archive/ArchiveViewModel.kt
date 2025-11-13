package com.example.inventoryapp.ui.archive

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.dao.PackageWithCount
import com.example.inventoryapp.data.repository.ContractorRepository
import com.example.inventoryapp.data.repository.PackageRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

/**
 * ViewModel for Archive screen - manages archived packages display and filtering
 */
class ArchiveViewModel(
    private val packageRepository: PackageRepository,
    private val contractorRepository: ContractorRepository
) : ViewModel() {

    // All archived packages from database
    private val allArchivedPackages = packageRepository.getArchivedPackagesWithCount()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // Search query
    private val _searchQuery = MutableStateFlow("")

    // Filtered packages based on search
    val filteredPackages: StateFlow<List<PackageWithCount>> = combine(
        allArchivedPackages,
        _searchQuery
    ) { packages, query ->
        if (query.isBlank()) {
            packages
        } else {
            packages.filter { pkgWithCount ->
                pkgWithCount.packageEntity.name.contains(query, ignoreCase = true)
            }
        }
    }.stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    /**
     * Set search query for filtering packages
     */
    fun setSearchQuery(query: String) {
        _searchQuery.value = query
    }

    /**
     * Unarchive a package (restore to active packages)
     */
    fun unarchivePackage(packageId: Long) {
        viewModelScope.launch {
            packageRepository.unarchivePackage(packageId)
        }
    }
}

/**
 * Factory for creating ArchiveViewModel with dependencies
 */
class ArchiveViewModelFactory(
    private val packageRepository: PackageRepository,
    private val contractorRepository: ContractorRepository
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ArchiveViewModel::class.java)) {
            return ArchiveViewModel(packageRepository, contractorRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
