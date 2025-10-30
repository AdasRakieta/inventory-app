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

        /**
         * Generate ZPL content with QR code for data export/import
         * QR code is ALWAYS 4cm x 4cm (157 dots at 203 DPI) for consistent scanning
         * Optimized for 48mm thermal paper rolls
         * @param qrData Data to encode in QR code (JSON string)
         * @param title Optional title to display above QR code
         * @param dpi Printer DPI (default 203)
         */
        fun generateQRCodeLabel(
            qrData: String,
            title: String = "Inventory Data",
            dpi: Int = DPI_203
        ): String {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
            val formattedDate = dateFormat.format(Date())

            // Label dimensions for 48mm width paper
            val labelWidth = 384  // 48mm at 203 DPI

            // FIXED QR CODE SIZE: 4cm x 4cm
            // At 203 DPI: 4cm = 1.575 inches = 1.575 * 203 = 320 dots
            // We'll use module size and magnification to achieve this
            // ZPL ^BQ command: ^BQo,m,e where m = magnification (1-10)
            // For 4cm QR at 203 DPI, we need magnification = 8
            val qrMagnification = 3  // Fixed magnification for 4cm QR code
            val qrActualSize = 320   // 4cm at 203 DPI = 320 dots

            // Left-align the QR code with margin
            val qrX = 30  // Left margin

            // Y positions for layout
            val titleY = 50
            val qrY = 100          // After title
            val dateLabelY = qrY + qrActualSize + 200  // After QR + spacing
            val dateValueY = dateLabelY + 50

            // Calculate total height dynamically
            val totalHeight = dateValueY + 400  // Date line + bottom margin

            return """
                ^XA
                ^PW$labelWidth
                ^LL$totalHeight
                ^FO30,$titleY^A0N,25,25^FD$title^FS
                ^FO$qrX,$qrY^BQN,2,$qrMagnification^FDMA,$qrData^FS
                ^FO30,$dateLabelY^A0N,20,20^FDGenerated:^FS
                ^FO30,$dateValueY^A0N,20,20^FD$formattedDate^FS
                ^XZ
            """.trimIndent()
        }

        /**
         * Calculate optimal QR code magnification to fit within available width
         * @param dataLength Length of data to encode
         * @param availableWidth Available width in dots
         * @return Optimal magnification level (1-10)
         */
        private fun calculateOptimalQRMagnification(dataLength: Int, availableWidth: Int): Int {
            // Base magnification based on data size
            // QR codes can hold roughly 100-200 chars per magnification level increase
            val baseMagnification = when {
                dataLength <= 100 -> 5    // Small data - larger QR for better readability
                dataLength <= 500 -> 4    // Medium data
                dataLength <= 1000 -> 3   // Large data
                dataLength <= 2000 -> 2   // Very large data
                else -> 1                 // Extremely large data
            }

            // Calculate approximate QR size (magnification * ~50 dots)
            val estimatedQRSize = baseMagnification * 50

            // If QR fits, use base magnification
            if (estimatedQRSize <= availableWidth) {
                return baseMagnification
            }

            // Otherwise, scale down to fit available width
            val maxMagnification = (availableWidth / 50).coerceAtLeast(1)
            return maxMagnification.coerceAtMost(baseMagnification)
        }
    }
}