package com.example.inventoryapp.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "packages")
data class PackageEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val contractorId: Long? = null, // Optional contractor assignment
    val status: String = "PREPARATION", // PREPARATION, READY, SHIPPED, DELIVERED
    val createdAt: Long = System.currentTimeMillis(),
    val shippedAt: Long? = null,
    val deliveredAt: Long? = null
)
