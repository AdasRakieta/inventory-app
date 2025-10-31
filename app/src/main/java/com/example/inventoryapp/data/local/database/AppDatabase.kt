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
        ContractorEntity::class,
        BoxEntity::class,
        BoxProductCrossRef::class,
        ImportBackupEntity::class
    ],
    version = 10,
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
    abstract fun boxDao(): BoxDao
    abstract fun importBackupDao(): ImportBackupDao

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

        // Migration 5 -> 6: Add description column to products table
        private val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add description column to products table
                database.execSQL("ALTER TABLE products ADD COLUMN description TEXT")
            }
        }

        // Migration 6 -> 7: Add boxes table and box_product_cross_ref table
        private val MIGRATION_6_7 = object : Migration(6, 7) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Create boxes table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS `boxes` (
                        `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        `name` TEXT NOT NULL,
                        `description` TEXT,
                        `warehouseLocation` TEXT,
                        `createdAt` INTEGER NOT NULL,
                        `updatedAt` INTEGER NOT NULL
                    )
                """.trimIndent())

                // Create box_product_cross_ref table
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS `box_product_cross_ref` (
                        `boxId` INTEGER NOT NULL,
                        `productId` INTEGER NOT NULL,
                        `addedAt` INTEGER NOT NULL,
                        PRIMARY KEY(`boxId`, `productId`),
                        FOREIGN KEY(`boxId`) REFERENCES `boxes`(`id`) ON DELETE CASCADE,
                        FOREIGN KEY(`productId`) REFERENCES `products`(`id`) ON DELETE CASCADE
                    )
                """.trimIndent())

                // Create indices
                database.execSQL("CREATE INDEX IF NOT EXISTS `index_box_product_cross_ref_boxId` ON `box_product_cross_ref` (`boxId`)")
                database.execSQL("CREATE INDEX IF NOT EXISTS `index_box_product_cross_ref_productId` ON `box_product_cross_ref` (`productId`)")
            }
        }

        private val MIGRATION_7_8 = object : Migration(7, 8) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Create import_backups table for undo functionality
                database.execSQL("""
                    CREATE TABLE IF NOT EXISTS `import_backups` (
                        `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        `backupTimestamp` INTEGER NOT NULL,
                        `backupJson` TEXT NOT NULL,
                        `importDescription` TEXT NOT NULL,
                        `productsCount` INTEGER NOT NULL,
                        `packagesCount` INTEGER NOT NULL,
                        `templatesCount` INTEGER NOT NULL
                    )
                """.trimIndent())
            }
        }

        private val MIGRATION_8_9 = object : Migration(8, 9) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add requiresSerialNumber column to categories table
                database.execSQL("ALTER TABLE `categories` ADD COLUMN `requiresSerialNumber` INTEGER NOT NULL DEFAULT 1")
                
                // Create "Other" category that doesn't require serial numbers
                database.execSQL("""
                    INSERT INTO `categories` (`name`, `iconResId`, `requiresSerialNumber`, `createdAt`)
                    VALUES ('Other', 0, 0, ${System.currentTimeMillis()})
                """.trimIndent())
            }
        }

        private val MIGRATION_9_10 = object : Migration(9, 10) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add quantity column to products table for aggregated products (especially "Other" category)
                database.execSQL("ALTER TABLE `products` ADD COLUMN `quantity` INTEGER NOT NULL DEFAULT 1")
            }
        }

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "inventory_database"
                )
                    .addMigrations(MIGRATION_1_2, MIGRATION_2_3, MIGRATION_3_4, MIGRATION_4_5, MIGRATION_5_6, MIGRATION_6_7, MIGRATION_7_8, MIGRATION_8_9, MIGRATION_9_10)
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
