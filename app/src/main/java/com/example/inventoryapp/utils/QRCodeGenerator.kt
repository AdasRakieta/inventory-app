package com.example.inventoryapp.utils

import android.graphics.Bitmap
import android.graphics.Color
import com.google.gson.Gson
import com.google.zxing.BarcodeFormat
import com.google.zxing.MultiFormatWriter
import com.google.zxing.common.BitMatrix

/**
 * Utility for QR code generation and data serialization
 */
object QRCodeGenerator {
    
    // Made public to allow inline function access
    val gson = Gson()
    
    /**
     * Generate QR code bitmap from data object
     */
    fun <T> generateQRCode(data: T, width: Int = 512, height: Int = 512): Bitmap? {
        return try {
            val jsonString = gson.toJson(data)
            val bitMatrix = MultiFormatWriter().encode(
                jsonString,
                BarcodeFormat.QR_CODE,
                width,
                height
            )
            bitMatrix.toBitmap()
        } catch (e: Exception) {
            e.printStackTrace()
            null
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
