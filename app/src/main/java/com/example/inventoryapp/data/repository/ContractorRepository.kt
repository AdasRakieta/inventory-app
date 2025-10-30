package com.example.inventoryapp.data.repository

import com.example.inventoryapp.data.local.dao.ContractorDao
import com.example.inventoryapp.data.local.entities.ContractorEntity
import kotlinx.coroutines.flow.Flow

class ContractorRepository(private val contractorDao: ContractorDao) {

    fun getAllContractors(): Flow<List<ContractorEntity>> = contractorDao.getAllContractors()

    suspend fun getContractorById(contractorId: Long): ContractorEntity? = contractorDao.getContractorById(contractorId)

    suspend fun insertContractor(contractor: ContractorEntity): Long = contractorDao.insertContractor(contractor)

    suspend fun updateContractor(contractor: ContractorEntity) = contractorDao.updateContractor(contractor)

    suspend fun deleteContractor(contractor: ContractorEntity) = contractorDao.deleteContractor(contractor)

    suspend fun getContractorCount(): Int = contractorDao.getContractorCount()
}