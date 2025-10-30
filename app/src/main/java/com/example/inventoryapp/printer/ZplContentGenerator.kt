package com.example.inventoryapp.printer

import java.text.SimpleDateFormat
import java.util.*

class ZplContentGenerator {

    companion object {
        private const val DPI_203 = 203
        private const val DPI_300 = 300

        // Default label dimensions (in dots for 203 DPI)
        private const val DEFAULT_LABEL_WIDTH = 576  // 3 inches at 203 DPI
        private const val DEFAULT_LABEL_HEIGHT = 324 // 1.6 inches at 203 DPI

        /**
         * Generate ZPL content for inventory item label
         */
        fun generateInventoryLabel(
            itemCode: String,
            itemName: String,
            quantity: Int,
            location: String,
            timestamp: Date = Date(),
            dpi: Int = DPI_203
        ): String {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
            val formattedDate = dateFormat.format(timestamp)

            return """
                ^XA
                ^PW${DEFAULT_LABEL_WIDTH}
                ^LL${DEFAULT_LABEL_HEIGHT}
                ^FO50,30^A0N,30,30^FDItem Code:^FS
                ^FO50,70^A0N,40,40^FD$itemCode^FS
                ^FO50,130^A0N,25,25^FD$itemName^FS
                ^FO50,170^A0N,20,20^FDQty: $quantity^FS
                ^FO50,200^A0N,20,20^FDLocation: $location^FS
                ^FO50,230^A0N,15,15^FD$formattedDate^FS
                ^FO400,30^BQN,2,4^FDMM,A$itemCode^FS
                ^XZ
            """.trimIndent()
        }

        /**
         * Generate ZPL content for inventory summary label
         */
        fun generateInventorySummaryLabel(
            totalItems: Int,
            totalQuantity: Int,
            location: String,
            timestamp: Date = Date(),
            dpi: Int = DPI_203
        ): String {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
            val formattedDate = dateFormat.format(timestamp)

            return """
                ^XA
                ^PW${DEFAULT_LABEL_WIDTH}
                ^LL${DEFAULT_LABEL_HEIGHT}
                ^FO50,30^A0N,35,35^FDInventory Summary^FS
                ^FO50,80^A0N,25,25^FDTotal Items: $totalItems^FS
                ^FO50,120^A0N,25,25^FDTotal Quantity: $totalQuantity^FS
                ^FO50,160^A0N,20,20^FDLocation: $location^FS
                ^FO50,190^A0N,15,15^FD$formattedDate^FS
                ^XZ
            """.trimIndent()
        }

        /**
         * Generate ZPL content for location label
         */
        fun generateLocationLabel(
            locationCode: String,
            locationName: String,
            description: String? = null,
            dpi: Int = DPI_203
        ): String {
            val descText = description?.let { "\n^FO50,160^A0N,20,20^FD$it^FS" } ?: ""

            return """
                ^XA
                ^PW${DEFAULT_LABEL_WIDTH}
                ^LL${DEFAULT_LABEL_HEIGHT}
                ^FO50,30^A0N,35,35^FDLocation^FS
                ^FO50,80^A0N,30,30^FD$locationCode^FS
                ^FO50,120^A0N,25,25^FD$locationName^FS$descText
                ^FO400,30^BQN,2,4^FDMM,A$locationCode^FS
                ^XZ
            """.trimIndent()
        }

        /**
         * Generate ZPL content for custom text label
         */
        fun generateTextLabel(
            title: String,
            content: String,
            subtitle: String? = null,
            dpi: Int = DPI_203
        ): String {
            val subtitleText = subtitle?.let { "\n^FO50,120^A0N,20,20^FD$it^FS" } ?: ""

            return """
                ^XA
                ^PW${DEFAULT_LABEL_WIDTH}
                ^LL${DEFAULT_LABEL_HEIGHT}
                ^FO50,30^A0N,35,35^FD$title^FS
                ^FO50,80^A0N,25,25^FD$content^FS$subtitleText
                ^XZ
            """.trimIndent()
        }

        /**
         * Generate test ZPL content to verify printer functionality
         */
        fun generateTestLabel(dpi: Int = DPI_203): String {
            return """
                ^XA
                ^PW${DEFAULT_LABEL_WIDTH}
                ^LL${DEFAULT_LABEL_HEIGHT}
                ^FO50,30^A0N,35,35^FDPrinter Test^FS
                ^FO50,80^A0N,25,25^FDHello Zebra!^FS
                ^FO50,120^A0N,20,20^FDTest successful^FS
                ^FO50,160^A0N,15,15^FD${Date()}^FS
                ^XZ
            """.trimIndent()
        }
    }
}