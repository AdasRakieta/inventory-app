package com.example.inventoryapp.utils

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.util.Log
import androidx.core.content.ContextCompat
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.OutputStream
import java.util.Date
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
         * Note: BLUETOOTH and BLUETOOTH_ADMIN are normal permissions on API ≤30 (auto-granted at install)
         */
        suspend fun scanPrinters(context: Context): List<BluetoothDevice> = withContext(Dispatchers.IO) {
            try {
                val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
                    Log.w(TAG, "Bluetooth not available or not enabled")
                    return@withContext emptyList()
                }
                
                @Suppress("MissingPermission")
                val pairedDevices = bluetoothAdapter.bondedDevices
                // Filter devices that might be printers
                pairedDevices.filter { device ->
                    @Suppress("MissingPermission")
                    val name = device.name?.toLowerCase() ?: ""
                    name.contains("printer") || 
                    name.contains("print") || 
                    name.contains("pos") ||
                    name.contains("thermal")
                }
            } catch (e: SecurityException) {
                Log.e(TAG, "Security exception - missing Bluetooth permissions", e)
                emptyList()
            } catch (e: Exception) {
                Log.e(TAG, "Error scanning for printers", e)
                emptyList()
            }
        }
        
        /**
         * Connect to printer by MAC address scanned from QR code
         * Enhanced with fallback mechanisms for Zebra printers (e.g., ZQ310 Plus)
         * Note: BLUETOOTH and BLUETOOTH_ADMIN are normal permissions on API ≤30 (auto-granted at install)
         */
    suspend fun connectToPrinter(context: Context, macAddress: String): BluetoothSocket? = withContext(Dispatchers.IO) {
            try {
                val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
                    Log.w(TAG, "Bluetooth not available or not enabled")
                    return@withContext null
                }
                
                val device = bluetoothAdapter.getRemoteDevice(macAddress)
                
                // Cancel discovery to improve connection speed
                @Suppress("MissingPermission")
                bluetoothAdapter.cancelDiscovery()
                
                // Try multiple connection methods for better compatibility
                // Reordered to PREFER INSECURE methods first (no pairing required)
                var socket: BluetoothSocket? = null

                // Method 1: Reflection-based INSECURE connection on channel 1 (commonly works on Zebra)
                try {
                    @Suppress("MissingPermission")
                    val insecureMethod = runCatching {
                        device.javaClass.getMethod("createInsecureRfcommSocket", Int::class.javaPrimitiveType)
                    }.getOrNull()
                    if (insecureMethod != null) {
                        socket = insecureMethod.invoke(device, 1) as BluetoothSocket
                        socket.connect()
                        @Suppress("MissingPermission")
                        Log.d(TAG, "Connected (insecure, ch1 via reflection): ${device.name}")
                        return@withContext socket
                    }
                } catch (e: Exception) {
                    socket?.close()
                    Log.w(TAG, "Insecure reflection connection failed, trying insecure SPP", e)
                }

                // Method 2: Insecure RFCOMM over SPP UUID (no pairing/bonding)
                try {
                    @Suppress("MissingPermission")
                    socket = device.createInsecureRfcommSocketToServiceRecord(SPP_UUID)
                    socket.connect()
                    @Suppress("MissingPermission")
                    Log.d(TAG, "Connected (insecure SPP): ${device.name}")
                    return@withContext socket
                } catch (e: Exception) {
                    socket?.close()
                    Log.w(TAG, "Insecure SPP failed, trying secure reflection ch1", e)
                }

                // Method 3: Reflection-based SECURE connection (channel 1)
                try {
                    @Suppress("MissingPermission")
                    val method = device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType)
                    socket = method.invoke(device, 1) as BluetoothSocket
                    socket.connect()
                    @Suppress("MissingPermission")
                    Log.d(TAG, "Connected (secure reflection ch1): ${device.name}")
                    return@withContext socket
                } catch (e: Exception) {
                    socket?.close()
                    Log.w(TAG, "Secure reflection failed, trying secure SPP (may prompt pairing)", e)
                }

                // Method 4: Standard SPP (SECURE) as the last resort
                try {
                    @Suppress("MissingPermission")
                    socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                    socket.connect()
                    @Suppress("MissingPermission")
                    Log.d(TAG, "Connected (secure SPP): ${device.name}")
                    return@withContext socket
                } catch (e: Exception) {
                    socket?.close()
                    Log.e(TAG, "All connection methods failed", e)
                }
                
                null
            } catch (e: SecurityException) {
                Log.e(TAG, "Security exception - missing Bluetooth permissions", e)
                null
            } catch (e: Exception) {
                Log.e(TAG, "Error connecting to printer", e)
                null
            }
        }
        
        /**
         * Send raw ZPL content to Zebra printer
         * @param socket Active Bluetooth socket connection
         * @param zplContent Complete ZPL program (including ^XA and ^XZ)
         * @return true if sent successfully, false otherwise
         */
        suspend fun printZpl(
            socket: BluetoothSocket,
            zplContent: String
        ): Boolean = withContext(Dispatchers.IO) {
            var outputStream: OutputStream? = null
            try {
                outputStream = socket.outputStream
                
                // Try to switch the printer to ZPL language first (Zebra SGD command)
                runCatching {
                    val sgd = "! U1 setvar \"device.languages\" \"zpl\"\r\n".toByteArray(Charsets.UTF_8)
                    Log.d(TAG, "Sending SGD language switch command")
                    outputStream.write(sgd)
                    outputStream.flush()
                    Thread.sleep(100) // Wait for language switch
                    Log.d(TAG, "SGD language switch sent successfully")
                }.onFailure { e ->
                    Log.w(TAG, "Failed to send SGD language switch", e)
                }

                // Send ZPL program
                val zplBytes = zplContent.toByteArray(Charsets.UTF_8)
                Log.d(TAG, "Sending ZPL content (${zplBytes.size} bytes)")
                outputStream.write(zplBytes)
                outputStream.flush()
                Thread.sleep(200) // Wait for printing
                Log.d(TAG, "ZPL sent successfully")

                true
            } catch (e: Exception) {
                Log.e(TAG, "Error sending ZPL", e)
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
         * Print QR code bitmap via Bluetooth
         */
        suspend fun printQRCode(
            socket: BluetoothSocket,
            qrBitmap: Bitmap,
            headerText: String? = null,
            footerText: String? = null,
            qrData: String? = null
        ): Boolean = withContext(Dispatchers.IO) {
            var outputStream: OutputStream? = null
            try {
                outputStream = socket.outputStream
                
                // If qrData is provided, prefer sending ZPL (Zebra-compatible, no bitmap threshold issues)
                if (!qrData.isNullOrEmpty()) {
                    // Try to switch the printer to ZPL language first (Zebra SGD command)
                    runCatching {
                        val sgd = "! U1 setvar \"device.languages\" \"zpl\"\r\n".toByteArray(Charsets.UTF_8)
                        Log.d(TAG, "Sending SGD language switch command: ${String(sgd, Charsets.UTF_8).trim()}")
                        outputStream.write(sgd)
                        outputStream.flush()
                        Thread.sleep(100) // Increased delay for language switch
                        Log.d(TAG, "SGD language switch sent successfully")
                    }.onFailure { e ->
                        Log.w(TAG, "Failed to send SGD language switch", e)
                    }

                    // Send ZPL program
                    val zpl = buildZplForQr(qrData, headerText, footerText)
                    Log.d(TAG, "Sending ZPL QR data (${zpl.size} bytes): ${String(zpl, Charsets.UTF_8).take(200)}...")
                    outputStream.write(zpl)
                    outputStream.flush()
                    Thread.sleep(200) // Wait for processing
                    Log.d(TAG, "Sent ZPL QR successfully")

                    // NOTE: Removed CPCL fallback to prevent duplicate printing
                    // If ZPL doesn't work, the ESC/POS fallback below will be used instead
                    return@withContext true
                }

                // ESC/POS fallback (for generic thermal printers)
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
                Log.d(TAG, "QR code printed successfully (ESC/POS)")
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

        // Build a minimal ZPL program for QR with optional header/footer
        private fun buildZplForQr(data: String, header: String?, footer: String?): ByteArray {
            // Calculate dynamic label height based on content
            var totalHeight = 50 // Top margin

            // Calculate header height
            if (!header.isNullOrEmpty()) {
                val headerLines = header.lines()
                totalHeight += headerLines.size * 28 // 28 points per line
                totalHeight += 10 // spacing after header
            }

            // Calculate QR magnification and height
            val qrMagnification = when {
                data.length <= 100 -> 6    // Small data - larger QR for better readability
                data.length <= 500 -> 5    // Medium data
                data.length <= 1000 -> 4   // Large data
                data.length <= 2000 -> 3   // Very large data
                else -> 2                  // Extremely large data
            }
            val qrHeight = qrMagnification * 110 // QR code height
            totalHeight += qrHeight + 30 // QR + spacing after

            // Calculate footer height
            if (!footer.isNullOrEmpty()) {
                val footerLines = footer.lines()
                totalHeight += footerLines.size * 26 // 26 points per line
            }

            // Add bottom margin
            totalHeight += 50

            // Ensure minimum height
            totalHeight = maxOf(totalHeight, 400)

            // 384 dots width (~48mm at 203dpi)
            val sb = StringBuilder()
            sb.append("^XA\r\n")
            sb.append("^PW384\r\n") // print width (dots)
            sb.append("^LL$totalHeight\r\n") // dynamic label length (dots)
            sb.append("^LH0,0\r\n")  // label home
            sb.append("^CI28\r\n") // UTF-8
            sb.append("^XZ\r\n") // close any partial format (defensive)
            sb.append("^XA\r\n")
            sb.append("^PW384\r\n^LL$totalHeight\r\n^LH0,0\r\n^CI28\r\n")

            // Header (optional), print as multiline text at top
            var y = 50  // Top margin
            if (!header.isNullOrEmpty()) {
                header.lines().forEach { line ->
                    sb.append("^FO20,$y^A0N,24,24^FB344,1,0,C,0^FD").append(line).append("^FS\r\n")
                    y += 28
                }
                y += 10
            }

            // QR code block - positioned on the left
            sb.append("^FO20,$y\r\n") // Left-aligned QR code
            sb.append("^BQN,2,$qrMagnification\r\n")  // Model 2, calculated magnification
            sb.append("^FDLA,").append(data).append("^FS\r\n")

            // Move y position past QR code
            y += qrHeight + 30

            // Footer (optional) - positioned below QR
            if (!footer.isNullOrEmpty()) {
                footer.lines().forEach { line ->
                    sb.append("^FO20,$y^A0N,22,22^FB344,1,0,L,0^FD").append(line).append("^FS\r\n")
                    y += 26
                }
            }

            sb.append("^PQ1\r\n^XZ\r\n")
            return sb.toString().toByteArray(Charsets.UTF_8)
        }

        // CPCL fallback program for QR (mobile Zebra often supports CPCL)
        private fun buildCpclForQr(data: String, header: String?, footer: String?): ByteArray {
            val sb = StringBuilder()
            //! 0 <hres> <vres> <height> <qty>
            sb.append("! 0 200 200 400 1\r\n")
            sb.append("PW 384\r\n") // print width
            sb.append("SETMAG 0 0\r\n")
            var y = 20
            if (!header.isNullOrEmpty()) {
                header.lines().forEach { line ->
                    sb.append("CENTER\r\n")
                    sb.append("T 0 24 0 $y ").append(line).append("\r\n")
                    y += 28
                }
                y += 10
            }
            sb.append("CENTER\r\n")
            sb.append("B QR 0 $y M 2 U 6\r\n") // model 2, unit size 6
            sb.append("MA,").append(data).append("\r\n")
            sb.append("ENDQR\r\n")
            y += 220
            if (!footer.isNullOrEmpty()) {
                footer.lines().forEach { line ->
                    sb.append("CENTER\r\n")
                    sb.append("T 0 22 0 $y ").append(line).append("\r\n")
                    y += 24
                }
            }
            sb.append("PRINT\r\n")
            return sb.toString().toByteArray(Charsets.UTF_8)
        }
        
        /**
         * Print plain text content via Bluetooth
         */
        suspend fun printText(
            socket: BluetoothSocket,
            textContent: String
        ): Boolean = withContext(Dispatchers.IO) {
            var outputStream: OutputStream? = null
            try {
                outputStream = socket.outputStream

                // Try ZPL mode first (for Zebra printers)
                runCatching {
                    val sgd = "! U1 setvar \"device.languages\" \"zpl\"\r\n".toByteArray(Charsets.UTF_8)
                    Log.d(TAG, "Sending SGD language switch command: ${String(sgd, Charsets.UTF_8).trim()}")
                    outputStream.write(sgd)
                    outputStream.flush()
                    Thread.sleep(100)
                    Log.d(TAG, "SGD language switch sent successfully")
                }.onFailure { e ->
                    Log.w(TAG, "Failed to send SGD language switch", e)
                }

                // Send ZPL text content
                val zplContent = buildZplForText(textContent)
                Log.d(TAG, "Sending ZPL text (${zplContent.size} bytes)")
                outputStream.write(zplContent)
                outputStream.flush()
                Thread.sleep(200)
                Log.d(TAG, "Sent ZPL text successfully")

                true
            } catch (e: Exception) {
                Log.e(TAG, "Error printing text", e)
                false
            } finally {
                try {
                    outputStream?.flush()
                } catch (e: Exception) {
                    Log.e(TAG, "Error flushing output stream", e)
                }
            }
        }
        
        // Build ZPL program for plain text content
        private fun buildZplForText(textContent: String): ByteArray {
            val lines = textContent.lines()
            
            // Calculate dynamic height based on number of lines
            val totalHeight = 50 + (lines.size * 28) + 50 // top margin + lines + bottom margin
            
            val sb = StringBuilder()
            sb.append("^XA\r\n")
            sb.append("^PW384\r\n") // print width (dots)
            sb.append("^LL$totalHeight\r\n") // dynamic label length (dots)
            sb.append("^LH0,0\r\n")  // label home
            sb.append("^CI28\r\n") // UTF-8
            
            // Print each line of text
            var y = 50 // Start position
            lines.forEach { line ->
                if (line.isNotBlank()) {
                    sb.append("^FO20,$y^A0N,24,24^FB344,1,0,L,0^FD").append(line).append("^FS\r\n")
                }
                y += 28
            }
            
            sb.append("^PQ1\r\n^XZ\r\n")
            return sb.toString().toByteArray(Charsets.UTF_8)
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
            // Use higher threshold to prevent "black blob" effect on QR codes
            for (y in 0 until height) {
                for (x in 0 until widthBytes) {
                    var byte = 0
                    for (bit in 0 until 8) {
                        val pixelX = x * 8 + bit
                        if (pixelX < width) {
                            val pixel = scaledBitmap.getPixel(pixelX, y)
                            // Extract RGB channels
                            val red = (pixel shr 16) and 0xFF
                            val green = (pixel shr 8) and 0xFF
                            val blue = pixel and 0xFF
                            
                            // Calculate brightness (0-255)
                            val brightness = (red + green + blue) / 3
                            
                            // Stricter threshold: only print truly dark pixels
                            // This prevents QR codes from becoming black blobs
                            if (brightness < 100) { // Only very dark pixels
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
         * Send test label to verify printer functionality
         */
        suspend fun sendTestLabel(socket: BluetoothSocket): Boolean = withContext(Dispatchers.IO) {
            var outputStream: OutputStream? = null
            try {
                outputStream = socket.outputStream

                // Force ZPL mode
                runCatching {
                    val sgd = "! U1 setvar \"device.languages\" \"zpl\"\r\n".toByteArray(Charsets.UTF_8)
                    Log.d(TAG, "Test: Sending SGD language switch")
                    outputStream.write(sgd)
                    outputStream.flush()
                    Thread.sleep(200)
                }

                // Send simple test ZPL label
                val testZpl = """
                    ^XA
                    ^PW384
                    ^LL200
                    ^FO50,30^A0N,35,35^FDTEST LABEL^FS
                    ^FO50,80^A0N,25,25^FDPrinter working!^FS
                    ^FO50,120^A0N,20,20^FD${Date()}^FS
                    ^PQ1
                    ^XZ
                """.trimIndent().toByteArray(Charsets.UTF_8)

                Log.d(TAG, "Test: Sending test ZPL (${testZpl.size} bytes)")
                outputStream.write(testZpl)
                outputStream.flush()
                Thread.sleep(500) // Wait for printing
                Log.d(TAG, "Test label sent successfully")
                true
            } catch (e: Exception) {
                Log.e(TAG, "Error sending test label", e)
                false
            } finally {
                try {
                    outputStream?.flush()
                } catch (e: Exception) {
                    Log.e(TAG, "Error flushing test output stream", e)
                }
            }
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
