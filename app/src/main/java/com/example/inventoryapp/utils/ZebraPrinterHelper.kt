package com.example.inventoryapp.utils

import android.os.Handler
import android.os.Looper
import com.zebra.sdk.comm.BluetoothConnectionInsecure
import com.zebra.sdk.comm.Connection
import com.zebra.sdk.printer.ZebraPrinterFactory
import com.zebra.sdk.printer.ZebraPrinterLinkOs
import java.util.concurrent.Executors

/**
 * Utility class for printing to Zebra printers via Bluetooth MAC address
 * Based on ok_mobile_zebra_printer Flutter plugin
 */
class ZebraPrinterHelper {

    private val executor = Executors.newSingleThreadExecutor()

    /**
     * Print ZPL document to Zebra printer
     * @param macAddress MAC address of the printer (e.g., "00:11:22:33:44:55")
     * @param zplMessage ZPL formatted print data
     * @param labelLength Label length setting (optional)
     * @param callback Callback with result or error message
     */
    fun printDocument(
        macAddress: String,
        zplMessage: String,
        labelLength: String? = null,
        callback: (String?) -> Unit
    ) {
        executor.execute {
            try {
                // Create Bluetooth connection
                val printerConn: Connection = BluetoothConnectionInsecure(macAddress)

                // Open connection
                printerConn.open()

                // Get printer instance
                val linkOsPrinter: ZebraPrinterLinkOs = ZebraPrinterFactory.getLinkOsPrinter(printerConn)

                // Set label length if provided
                labelLength?.let {
                    linkOsPrinter.setSetting("zpl.label_length", it)
                }

                // Send ZPL data
                printerConn.write(zplMessage.toByteArray(charset("windows-1250")))

                // Wait for printing to complete
                Thread.sleep(1000)

                // Close connection
                printerConn.close()

                // Success callback on main thread
                Handler(Looper.getMainLooper()).post {
                    callback(null) // null means success
                }

            } catch (e: Exception) {
                // Error callback on main thread
                Handler(Looper.getMainLooper()).post {
                    callback(e.message ?: "Unknown error")
                }
            }
        }
    }

    /**
     * Test printer connection
     * @param macAddress MAC address of the printer
     * @param callback Callback with connection status
     */
    fun testConnection(macAddress: String, callback: (Boolean, String?) -> Unit) {
        executor.execute {
            try {
                val printerConn: Connection = BluetoothConnectionInsecure(macAddress)
                printerConn.open()

                // Try to get printer info
                val linkOsPrinter: ZebraPrinterLinkOs = ZebraPrinterFactory.getLinkOsPrinter(printerConn)
                val printerInfo = linkOsPrinter.printerControlLanguage

                printerConn.close()

                Handler(Looper.getMainLooper()).post {
                    callback(true, "Connected successfully. Printer: $printerInfo")
                }

            } catch (e: Exception) {
                Handler(Looper.getMainLooper()).post {
                    callback(false, e.message ?: "Connection failed")
                }
            }
        }
    }

    /**
     * Clean up resources
     */
    fun shutdown() {
        executor.shutdown()
    }

    companion object {
        /**
         * Generate sample ZPL for testing
         */
        fun createTestZpl(productName: String, barcode: String): String {
            return """
                ^XA
                ^CF0,30
                ^FO50,50^FD$productName^FS
                ^FO50,100^BCN,100,Y,N,N^FD$barcode^FS
                ^XZ
            """.trimIndent()
        }
    }
}