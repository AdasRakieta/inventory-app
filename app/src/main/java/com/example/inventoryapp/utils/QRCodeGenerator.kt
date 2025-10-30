package com.example.inventoryapp.utils

import android.graphics.Bitmap
import android.graphics.Color
import android.util.Base64
import com.google.gson.Gson
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.MultiFormatWriter
import com.google.zxing.common.BitMatrix
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel
import java.io.ByteArrayOutputStream
import java.util.zip.GZIPOutputStream
import java.util.zip.GZIPInputStream

/**
 * Utility for QR code generation and data serialization with compression support
 */
object QRCodeGenerator {
    
    // Made public to allow inline function access
    val gson = Gson()
    
    // Maximum safe QR code data size (characters) - QR can hold ~4296 alphanumeric chars at max
    // We use conservative limit to ensure reliable scanning
    private const val MAX_QR_SIZE = 2000
    private const val MAX_QR_SIZE_COMPRESSED = 1500
    
    /**
     * Generate QR code bitmap from data object
     * Automatically compresses if data is too large
     */
    fun <T> generateQRCode(data: T, width: Int = 512, height: Int = 512): Bitmap? {
        return try {
            val jsonString = gson.toJson(data)
            
            // Try compressed version if data is large
            val qrData = if (jsonString.length > MAX_QR_SIZE) {
                compressAndEncode(jsonString)
            } else {
                jsonString
            }
            
            val hints = hashMapOf<EncodeHintType, Any>(
                EncodeHintType.ERROR_CORRECTION to ErrorCorrectionLevel.M,
                EncodeHintType.MARGIN to 1
            )
            
            val bitMatrix = MultiFormatWriter().encode(
                qrData,
                BarcodeFormat.QR_CODE,
                width,
                height,
                hints
            )
            bitMatrix.toBitmap()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * Generate multiple QR codes for large datasets (pagination)
     * Returns list of bitmaps, each containing a chunk of data
     */
    fun <T> generateMultiPartQRCodes(
        data: T, 
        width: Int = 512, 
        height: Int = 512
    ): List<Bitmap> {
        return try {
            val jsonString = gson.toJson(data)
            val compressed = compressAndEncode(jsonString)
            
            // If compressed data fits in one QR, return single QR
            if (compressed.length <= MAX_QR_SIZE_COMPRESSED) {
                val bitmap = generateQRCode(data, width, height)
                return if (bitmap != null) listOf(bitmap) else emptyList()
            }
            
            // Split into chunks
            val chunks = compressed.chunked(MAX_QR_SIZE_COMPRESSED)
            val totalParts = chunks.size
            
            chunks.mapIndexedNotNull { index, chunk ->
                val partData = mapOf(
                    "part" to (index + 1),
                    "total" to totalParts,
                    "data" to chunk
                )
                generateQRCodeFromString(gson.toJson(partData), width, height)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            emptyList()
        }
    }
    
    /**
     * Generate QR code from raw string (used internally)
     */
    private fun generateQRCodeFromString(data: String, width: Int, height: Int): Bitmap? {
        return try {
            val hints = hashMapOf<EncodeHintType, Any>(
                EncodeHintType.ERROR_CORRECTION to ErrorCorrectionLevel.M,
                EncodeHintType.MARGIN to 1
            )
            
            val bitMatrix = MultiFormatWriter().encode(
                data,
                BarcodeFormat.QR_CODE,
                width,
                height,
                hints
            )
            bitMatrix.toBitmap()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * Compress and Base64 encode data
     * Made public for use in printing workflows
     */
    fun compressAndEncode(data: String): String {
        val outputStream = ByteArrayOutputStream()
        GZIPOutputStream(outputStream).use { gzip ->
            gzip.write(data.toByteArray(Charsets.UTF_8))
        }
        return "GZIP:" + Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
    }
    
    /**
     * Decode and decompress data (if compressed)
     */
    fun decodeAndDecompress(data: String): String {
        return if (data.startsWith("GZIP:")) {
            val compressed = Base64.decode(data.substring(5), Base64.NO_WRAP)
            GZIPInputStream(compressed.inputStream()).use { gzip ->
                gzip.readBytes().toString(Charsets.UTF_8)
            }
        } else {
            data
        }
    }
    
    /**
     * Decode JSON string from QR scan to object
     */
    inline fun <reified T> decodeFromJson(jsonString: String): T? {
        return try {
            gson.fromJson(jsonString, T::class.java)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    private fun BitMatrix.toBitmap(): Bitmap {
        val width = this.width
        val height = this.height
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565)
        
        for (x in 0 until width) {
            for (y in 0 until height) {
                bitmap.setPixel(x, y, if (this[x, y]) Color.BLACK else Color.WHITE)
            }
        }
        return bitmap
    }
}
