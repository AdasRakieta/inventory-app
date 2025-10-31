package com.example.inventoryapp.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Entity representing a Bluetooth printer configuration
 */
@Entity(tableName = "printers")
data class PrinterEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    
    val name: String,
    val macAddress: String,
    
    // Label dimensions in millimeters
    val labelWidthMm: Int = 50,  // Default 50mm width
    val labelHeightMm: Int = 30, // Default 30mm height
    
    val isDefault: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)
