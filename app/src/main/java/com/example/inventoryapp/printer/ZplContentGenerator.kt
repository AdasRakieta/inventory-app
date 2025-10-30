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
         * Optimized for 48mm thermal paper rolls with sufficient height for QR code
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

            // Calculate available width for QR code (label width - left margin - right margin)
            val availableWidth = labelWidth - 40  // 20px left + 20px right margin = 344px available

            // Calculate optimal QR magnification based on data size and available space
            val qrMagnification = calculateOptimalQRMagnification(qrData.length, availableWidth)

            // Calculate actual QR code size based on magnification
            val qrSize = qrMagnification * 50  // Approximate size per magnification level

            // Align QR code to left with small margin
            val qrX = 20  // Left-aligned with margin

            // Y positions for dynamic layout with sufficient spacing
            val titleY = 90
            val qrY = 120          // After title (50px) + spacing (20px)
            val dateLabelY = 550  // After QR (270px) + spacing (80px) - increased space
            val dateValueY = 580  // Below "Generated:" label

            // Calculate total height dynamically - increased for full QR code height
            val totalHeight = dateValueY + 200  // Date line + bottom margin (430px)

            return """
                ^XA
                ^PW$labelWidth
                ^LL$totalHeight
                ^FO50,$titleY^A0N,30,30^FD$title^FS
                ^FO$qrX,$qrY^BQN,2,$qrMagnification^FDMA,$qrData^FS
                ^FO50,$dateLabelY^A0N,22,22^FDGenerated:^FS
                ^FO50,$dateValueY^A0N,22,22^FD$formattedDate^FS
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