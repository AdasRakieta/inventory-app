package com.example.inventoryapp

import android.app.Application
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.repository.BoxRepository
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.ImportBackupRepository

class InventoryApplication : Application() {
    
    private val database by lazy { AppDatabase.getDatabase(this) }
    val boxRepository by lazy { BoxRepository(database.boxDao(), database.productDao(), database.packageDao()) }
    val productRepository by lazy { ProductRepository(database.productDao()) }
    val importBackupRepository by lazy { ImportBackupRepository(database.importBackupDao()) }
    
    override fun onCreate() {
        super.onCreate()
        // Application initialization
    }
}
