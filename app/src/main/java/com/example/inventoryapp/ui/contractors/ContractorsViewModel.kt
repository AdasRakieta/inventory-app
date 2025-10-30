package com.example.inventoryapp.ui.contractors

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.inventoryapp.data.local.entities.ContractorEntity
import com.example.inventoryapp.data.repository.ContractorRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch

class ContractorsViewModel(private val contractorRepository: ContractorRepository) : ViewModel() {

    val allContractors: Flow<List<ContractorEntity>> = contractorRepository.getAllContractors()

    fun addContractor(
        name: String,
        contactPerson: String? = null,
        email: String? = null,
        phone: String? = null,
        address: String? = null,
        notes: String? = null
    ) {
        viewModelScope.launch {
            val contractor = ContractorEntity(
                name = name,
                contactPerson = contactPerson,
                email = email,
                phone = phone,
                address = address,
                notes = notes
            )
            contractorRepository.insertContractor(contractor)
        }
    }

    fun updateContractor(contractor: ContractorEntity) {
        viewModelScope.launch {
            val updatedContractor = contractor.copy(updatedAt = System.currentTimeMillis())
            contractorRepository.updateContractor(updatedContractor)
        }
    }

    fun deleteContractor(contractor: ContractorEntity) {
        viewModelScope.launch {
            contractorRepository.deleteContractor(contractor)
        }
    }
    
    suspend fun getContractorById(id: Long): ContractorEntity? {
        return contractorRepository.getContractorById(id)
    }
}