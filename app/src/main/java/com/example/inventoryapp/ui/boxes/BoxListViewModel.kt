package com.example.inventoryapp.ui.boxes

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.dao.BoxDao
import com.example.inventoryapp.data.local.dao.BoxWithCount
import com.example.inventoryapp.data.repository.BoxRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

/**
 * ViewModel for managing the box list screen.
 * Handles box search, filtering, and deletion.
 */
class BoxListViewModel(
    private val boxRepository: BoxRepository
) : ViewModel() {

    // Search query for filtering boxes
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    // List of all boxes with their product counts
    private val _boxes = MutableStateFlow<List<BoxWithCount>>(emptyList())
    val boxes: StateFlow<List<BoxWithCount>> = _boxes.asStateFlow()

    // Filtered boxes based on search query
    private val _filteredBoxes = MutableStateFlow<List<BoxWithCount>>(emptyList())
    val filteredBoxes: StateFlow<List<BoxWithCount>> = _filteredBoxes.asStateFlow()

    init {
        loadBoxes()
    }

    /**
     * Load all boxes from database
     */
    private fun loadBoxes() {
        viewModelScope.launch {
            try {
                boxRepository.getAllBoxesWithCount().collect { boxList ->
                    _boxes.value = boxList ?: emptyList()
                    applySearchFilter()
                }
            } catch (e: Exception) {
                // Log error and set empty list
                android.util.Log.e("BoxListViewModel", "Error loading boxes", e)
                _boxes.value = emptyList()
                _filteredBoxes.value = emptyList()
            }
        }
    }

    /**
     * Update search query and filter boxes
     */
    fun setSearchQuery(query: String) {
        _searchQuery.value = query
        applySearchFilter()
    }

    /**
     * Apply search filter to boxes
     */
    private fun applySearchFilter() {
        val query = _searchQuery.value.lowercase()
        _filteredBoxes.value = if (query.isEmpty()) {
            _boxes.value
        } else {
            _boxes.value.filter { boxWithCount ->
                boxWithCount.box.name.lowercase().contains(query) ||
                        boxWithCount.box.description?.lowercase()?.contains(query) == true ||
                        boxWithCount.box.warehouseLocation?.lowercase()?.contains(query) == true
            }
        }
    }

    /**
     * Delete a box by ID
     */
    fun deleteBox(boxId: Long) {
        viewModelScope.launch {
            boxRepository.deleteBox(boxId)
            // No need to manually reload - Flow will update automatically
        }
    }

    /**
     * Delete multiple boxes
     */
    fun deleteBoxes(boxIds: Set<Long>) {
        viewModelScope.launch {
            boxIds.forEach { boxId ->
                boxRepository.deleteBox(boxId)
            }
        }
    }
}

/**
 * Factory for creating BoxListViewModel with dependencies
 */
class BoxListViewModelFactory(
    private val boxRepository: BoxRepository
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(BoxListViewModel::class.java)) {
            return BoxListViewModel(boxRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
