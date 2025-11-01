package com.example.inventoryapp.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Entity representing a Bluetooth printer configuration
 * Printer uses its default settings (no size configuration needed)
 */
@Entity(tableName = "printers")
data class PrinterEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    
    val name: String,
    val macAddress: String,
    
    val isDefault: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)
