package com.example.inventoryapp

import android.app.Application
import android.util.Log
import androidx.room.Room
import com.example.inventoryapp.data.local.database.AppDatabase
import com.example.inventoryapp.data.local.dao.DeviceMovementDao
import com.example.inventoryapp.data.repository.BoxRepository
import com.example.inventoryapp.data.repository.ProductRepository
import com.example.inventoryapp.data.repository.ImportBackupRepository

class InventoryApplication : Application() {

    private val database by lazy {
        try {
            AppDatabase.getDatabase(this)
        } catch (e: Exception) {
            // Migration or DB open failed — fallback to destructive database to avoid crash
            Log.e("InventoryApp", "Database open failed, falling back to destructive migration", e)
            Room.databaseBuilder(
                applicationContext,
                AppDatabase::class.java,
                "inventory_database"
            )
                .fallbackToDestructiveMigration()
                .build()
        }
    }

    val boxRepository by lazy { BoxRepository(database.boxDao(), database.productDao(), database.packageDao(), database.deviceMovementDao()) }
    val productRepository by lazy { ProductRepository(database.productDao()) }
    val importBackupRepository by lazy { ImportBackupRepository(database.importBackupDao()) }

    override fun onCreate() {
        super.onCreate()
        // Application initialization
    }
}
