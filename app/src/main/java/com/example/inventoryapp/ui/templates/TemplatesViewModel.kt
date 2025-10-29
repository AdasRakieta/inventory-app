package com.example.inventoryapp.ui.templates

import androidx.lifecycle.ViewModel
<<<<<<< HEAD
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
=======
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ProductTemplateEntity
import com.example.inventoryapp.data.repository.ProductTemplateRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
import kotlinx.coroutines.launch

class TemplatesViewModel(
    private val repository: ProductTemplateRepository
) : ViewModel() {

<<<<<<< HEAD
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
=======
    private val _templates = MutableStateFlow<List<ProductTemplateEntity>>(emptyList())
    val templates: StateFlow<List<ProductTemplateEntity>> = _templates

    init {
        loadTemplates()
    }

    private fun loadTemplates() {
        viewModelScope.launch {
            repository.getAllTemplates().collect { templateList ->
                _templates.value = templateList
            }
        }
    }

    fun deleteTemplate(template: ProductTemplateEntity) {
        viewModelScope.launch {
            repository.deleteTemplate(template)
        }
    }

    suspend fun isTemplateNameExists(name: String): Boolean {
        return repository.isTemplateNameExists(name)
    }

    fun addTemplate(name: String, categoryId: Long?, description: String?) {
        viewModelScope.launch {
            val template = ProductTemplateEntity(
                name = name,
                categoryId = categoryId,
                description = description
            )
            repository.insertTemplate(template)
        }
    }

    fun updateTemplate(templateId: Long, name: String, categoryId: Long?, description: String?) {
        viewModelScope.launch {
            val template = ProductTemplateEntity(
                id = templateId,
                name = name,
                categoryId = categoryId,
                description = description,
                updatedAt = System.currentTimeMillis()
            )
            repository.updateTemplate(template)
        }
    }
}
>>>>>>> 38e7ca868b963369e9e301f0dc67297dce0cab91
