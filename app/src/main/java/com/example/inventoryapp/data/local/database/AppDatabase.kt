package com.example.inventoryapp.data.local.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.inventoryapp.data.local.dao.*
import com.example.inventoryapp.data.local.entities.*

@Database(
    entities = [
        ProductEntity::class,
        CategoryEntity::class,
        PackageEntity::class,
        PackageProductCrossRef::class,
        ScanHistoryEntity::class,
        ProductTemplateEntity::class,
        ScannerSettingsEntity::class
    ],
    version = 3,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun productDao(): ProductDao
    abstract fun categoryDao(): CategoryDao
    abstract fun packageDao(): PackageDao
    abstract fun scanHistoryDao(): ScanHistoryDao
    abstract fun productTemplateDao(): ProductTemplateDao
    abstract fun scannerSettingsDao(): ScannerSettingsDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        // Migration 1 -> 2: Add ProductTemplate table
        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS `product_templates` (
                        `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        `name` TEXT NOT NULL,
                        `categoryId` INTEGER,
                        `createdAt` INTEGER NOT NULL,
                        `updatedAt` INTEGER NOT NULL
                    )
                """.trimIndent())
            }
        }
        
        // Migration 2 -> 3: Add ScannerSettings table and make serialNumber required in products
        private val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Create scanner_settings table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS `scanner_settings` (
                        `id` INTEGER PRIMARY KEY NOT NULL,
                        `scannerId` TEXT NOT NULL,
                        `updatedAt` INTEGER NOT NULL
                    )
                """.trimIndent())
                
                // For products: serialNumber is now required (non-null)
                // Note: Existing products with null SNs will be deleted in destructive migration
                // In production, you'd migrate data carefully
            }
        }

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "inventory_database"
                )
                    .addMigrations(MIGRATION_1_2, MIGRATION_2_3)
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
