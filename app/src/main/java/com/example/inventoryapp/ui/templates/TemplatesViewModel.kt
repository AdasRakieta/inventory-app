package com.example.inventoryapp.ui.templates

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class TemplatesViewModel(
    private val repository: ProductTemplateRepository
) : ViewModel() {

    val templates: StateFlow<List<ProductTemplateEntity>> = repository.getAllTemplates()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    fun addTemplate(name: String, categoryId: Long? = null) {
        viewModelScope.launch {
            repository.addTemplate(name, categoryId)
        }
    }

    fun deleteTemplate(entity: ProductTemplateEntity) {
        viewModelScope.launch {
            repository.deleteTemplate(entity)
        }
    }
}

class TemplatesViewModelFactory(
    private val repository: ProductTemplateRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(TemplatesViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return TemplatesViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
