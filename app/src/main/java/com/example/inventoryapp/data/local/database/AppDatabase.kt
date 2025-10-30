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
        ScannerSettingsEntity::class,
        ContractorEntity::class
    ],
    version = 5,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun productDao(): ProductDao
    abstract fun categoryDao(): CategoryDao
    abstract fun packageDao(): PackageDao
    abstract fun scanHistoryDao(): ScanHistoryDao
    abstract fun productTemplateDao(): ProductTemplateDao
    abstract fun scannerSettingsDao(): ScannerSettingsDao
    abstract fun contractorDao(): ContractorDao

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

        // Migration 3 -> 4: Ensure unique index on products.serialNumber exists
        // Also remove duplicate non-null serial numbers to satisfy UNIQUE constraint
        private val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Remove duplicate rows keeping the lowest id for each non-null serialNumber
                database.execSQL(
                    """
                    DELETE FROM products
                    WHERE id NOT IN (
                        SELECT MIN(id)
                        FROM products
                        WHERE serialNumber IS NOT NULL
                        GROUP BY serialNumber
                    )
                    AND serialNumber IS NOT NULL
                    """.trimIndent()
                )

                // Create the unique index if it doesn't exist
                database.execSQL(
                    """
                    CREATE UNIQUE INDEX IF NOT EXISTS index_products_serialNumber
                    ON products(serialNumber)
                    """.trimIndent()
                )
            }
        }

        // Migration 4 -> 5: Add contractors table and contractorId column to packages
        private val MIGRATION_4_5 = object : Migration(4, 5) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Create contractors table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS `contractors` (
                        `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        `name` TEXT NOT NULL,
                        `contactPerson` TEXT,
                        `email` TEXT,
                        `phone` TEXT,
                        `address` TEXT,
                        `notes` TEXT,
                        `createdAt` INTEGER NOT NULL,
                        `updatedAt` INTEGER NOT NULL
                    )
                """.trimIndent())

                // Add contractorId column to packages table
                database.execSQL("ALTER TABLE packages ADD COLUMN contractorId INTEGER")
            }
        }

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "inventory_database"
                )
                    .addMigrations(MIGRATION_1_2, MIGRATION_2_3, MIGRATION_3_4, MIGRATION_4_5)
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
