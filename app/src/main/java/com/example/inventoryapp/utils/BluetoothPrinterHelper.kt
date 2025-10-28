package com.example.inventoryapp.utils

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.graphics.Bitmap
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.OutputStream
import java.util.UUID

/**
 * Helper class for printing QR codes via Bluetooth thermal printers
 * Supports ESC/POS command protocol
 */
class BluetoothPrinterHelper {

    companion object {
        private const val TAG = "BluetoothPrinter"
        
        // Standard UUID for Bluetooth Serial Port Profile (SPP)
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        
        // ESC/POS commands
        private val ESC_INIT = byteArrayOf(0x1B, 0x40) // Initialize printer
        private val ESC_ALIGN_CENTER = byteArrayOf(0x1B, 0x61, 0x01) // Center alignment
        private val ESC_ALIGN_LEFT = byteArrayOf(0x1B, 0x61, 0x00) // Left alignment
        private val ESC_CUT = byteArrayOf(0x1D, 0x56, 0x00) // Cut paper
        private val LINE_FEED = byteArrayOf(0x0A) // New line
        
        /**
         * Scan for paired Bluetooth devices
         * Returns list of printer-like devices (based on name patterns)
         */
        suspend fun scanPrinters(): List<BluetoothDevice> = withContext(Dispatchers.IO) {
            try {
                val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
                    Log.w(TAG, "Bluetooth not available or not enabled")
                    return@withContext emptyList()
                }
                
                val pairedDevices = bluetoothAdapter.bondedDevices
                // Filter devices that might be printers
                pairedDevices.filter { device ->
                    val name = device.name?.toLowerCase() ?: ""
                    name.contains("printer") || 
                    name.contains("print") || 
                    name.contains("pos") ||
                    name.contains("thermal")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error scanning for printers", e)
                emptyList()
            }
        }
        
        /**
         * Connect to printer by MAC address scanned from QR code
         */
        suspend fun connectToPrinter(macAddress: String): BluetoothSocket? = withContext(Dispatchers.IO) {
            try {
                val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
                    Log.w(TAG, "Bluetooth not available or not enabled")
                    return@withContext null
                }
                
                val device = bluetoothAdapter.getRemoteDevice(macAddress)
                val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                
                // Cancel discovery to improve connection speed
                bluetoothAdapter.cancelDiscovery()
                
                socket.connect()
                Log.d(TAG, "Connected to printer: ${device.name}")
                socket
            } catch (e: Exception) {
                Log.e(TAG, "Error connecting to printer", e)
                null
            }
        }
        
        /**
         * Print QR code bitmap via Bluetooth
         */
        suspend fun printQRCode(
            socket: BluetoothSocket,
            qrBitmap: Bitmap,
            headerText: String? = null,
            footerText: String? = null
        ): Boolean = withContext(Dispatchers.IO) {
            var outputStream: OutputStream? = null
            try {
                outputStream = socket.outputStream
                
                // Initialize printer
                outputStream.write(ESC_INIT)
                Thread.sleep(50)
                
                // Print header if provided
                if (!headerText.isNullOrEmpty()) {
                    outputStream.write(ESC_ALIGN_CENTER)
                    outputStream.write(headerText.toByteArray(Charsets.UTF_8))
                    outputStream.write(LINE_FEED)
                    outputStream.write(LINE_FEED)
                }
                
                // Convert bitmap to ESC/POS bitmap command
                val bitmapData = convertBitmapToESCPOS(qrBitmap)
                outputStream.write(ESC_ALIGN_CENTER)
                outputStream.write(bitmapData)
                outputStream.write(LINE_FEED)
                
                // Print footer if provided
                if (!footerText.isNullOrEmpty()) {
                    outputStream.write(LINE_FEED)
                    outputStream.write(ESC_ALIGN_CENTER)
                    outputStream.write(footerText.toByteArray(Charsets.UTF_8))
                    outputStream.write(LINE_FEED)
                }
                
                // Feed paper and cut
                outputStream.write(LINE_FEED)
                outputStream.write(LINE_FEED)
                outputStream.write(LINE_FEED)
                outputStream.write(ESC_CUT)
                
                outputStream.flush()
                Log.d(TAG, "QR code printed successfully")
                true
            } catch (e: Exception) {
                Log.e(TAG, "Error printing QR code", e)
                false
            } finally {
                try {
                    outputStream?.flush()
                } catch (e: Exception) {
                    Log.e(TAG, "Error flushing output stream", e)
                }
            }
        }
        
        /**
         * Convert bitmap to ESC/POS format
         * Uses raster bit image mode
         */
        private fun convertBitmapToESCPOS(bitmap: Bitmap): ByteArray {
            // Scale bitmap to printer width if needed (384 pixels for 58mm, 576 for 80mm)
            val maxWidth = 384
            val scaledBitmap = if (bitmap.width > maxWidth) {
                Bitmap.createScaledBitmap(
                    bitmap,
                    maxWidth,
                    (bitmap.height * maxWidth / bitmap.width),
                    false
                )
            } else {
                bitmap
            }
            
            val width = scaledBitmap.width
            val height = scaledBitmap.height
            
            // ESC/POS raster bit image command: GS v 0
            val result = mutableListOf<Byte>()
            result.add(0x1D) // GS
            result.add(0x76) // v
            result.add(0x30) // 0 (normal mode)
            result.add(0x00) // m (mode)
            
            // Width in bytes (width / 8)
            val widthBytes = (width + 7) / 8
            result.add((widthBytes and 0xFF).toByte())
            result.add(((widthBytes shr 8) and 0xFF).toByte())
            
            // Height in dots
            result.add((height and 0xFF).toByte())
            result.add(((height shr 8) and 0xFF).toByte())
            
            // Convert bitmap to monochrome bits
            for (y in 0 until height) {
                for (x in 0 until widthBytes) {
                    var byte = 0
                    for (bit in 0 until 8) {
                        val pixelX = x * 8 + bit
                        if (pixelX < width) {
                            val pixel = scaledBitmap.getPixel(pixelX, y)
                            // Check if pixel is dark (closer to black)
                            val brightness = (pixel shr 16 and 0xFF) + 
                                           (pixel shr 8 and 0xFF) + 
                                           (pixel and 0xFF)
                            if (brightness < 384) { // Threshold for black (< 128 * 3)
                                byte = byte or (1 shl (7 - bit))
                            }
                        }
                    }
                    result.add(byte.toByte())
                }
            }
            
            if (scaledBitmap != bitmap) {
                scaledBitmap.recycle()
            }
            
            return result.toByteArray()
        }
        
        /**
         * Close Bluetooth connection
         */
        fun disconnect(socket: BluetoothSocket?) {
            try {
                socket?.close()
                Log.d(TAG, "Disconnected from printer")
            } catch (e: Exception) {
                Log.e(TAG, "Error disconnecting", e)
            }
        }
    }
}
