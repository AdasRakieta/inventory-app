package com.example.inventoryapp.data.remote

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * Google Sheets API Service using OkHttp
 * Interacts with Google Apps Script API for inventory data synchronization
 */
class GoogleSheetsApiService {
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    private val gson = Gson()
    
    companion object {
        // Google Apps Script deployment URL (updated with correct endpoint)
        private const val BASE_URL = "https://script.google.com/macros/s/AKfycby6hGZzZoaqmGQATQYybAgLawO9VhVAnXomAE30FuXBRHXWkJoTeKFBdWf6kN5lSuHM/exec"
        
        // Sheet names to sync - must match exact names from Google Sheets
        // These correspond to KONFIGURACJA in GoogleSheetsRepository
        val SHEET_NAMES = listOf(
            "Skanery",
            "Drukarki",
            "Stacje do drukarek",
            "Stacje Dokujące",
            "Skanery tc27"
        )
    }
    
    /**
     * Fetch all items from a specific Google Sheet
     * @param sheetName Name of the sheet (e.g., "Skanery", "Drukarki")
     * @return List of items from the sheet
     */
    suspend fun fetchSheet(sheetName: String): List<GoogleSheetItem> = withContext(Dispatchers.IO) {
        try {
            val url = "$BASE_URL?arkusz=${sheetName}"
            println("[GoogleSheets] Fetching from URL: $url")
            
            val request = Request.Builder()
                .url(url)
                .get()
                .build()
            
            println("[GoogleSheets] Executing request for sheet: $sheetName")
            val response = client.newCall(request).execute()
            println("[GoogleSheets] Response code: ${response.code} for sheet: $sheetName")
            
            if (!response.isSuccessful) {
                val errorBody = response.body?.string() ?: "(empty body)"
                println("[GoogleSheets] ERROR: HTTP ${response.code} - $errorBody")
                throw IOException("HTTP error: ${response.code}")
            }
            
            val body = response.body?.string() ?: throw IOException("Empty response body")
            println("[GoogleSheets] Response body length: ${body.length} bytes for sheet: $sheetName")
            println("[GoogleSheets] Response body (first 500 chars): ${body.take(500)}")
            
            // Parse JSON array response directly to GoogleSheetItem
            // Gson will automatically map field names using @SerializedName annotations
            val typeToken = object : TypeToken<List<GoogleSheetItem>>() {}.type
            val items: List<GoogleSheetItem> = gson.fromJson(body, typeToken)
            
            println("[GoogleSheets] Successfully parsed ${items.size} items from $sheetName")
            items
        } catch (e: Exception) {
            println("[GoogleSheets] EXCEPTION fetching sheet $sheetName: ${e.message}")
            e.printStackTrace()
            throw IOException("Failed to fetch sheet $sheetName: ${e.message}", e)
        }
    }
    
    /**
     * Update an existing item in Google Sheets
     * @param sheetName Sheet to update
     * @param serialNumber Serial number (Skanery field) to update
     * @param kod Store/location code
     * @param nazwa Store/location name
     * @param status Status
     * @param firma Company name
     * @return API response
     */
    suspend fun updateItem(
        sheetName: String,
        serialNumber: String,
        kod: String? = null,
        nazwa: String? = null,
        status: String? = null,
        firma: String? = null
    ): ApiResponse = withContext(Dispatchers.IO) {
        try {
            val requestData = ApiRequest(
                akcja = "update",
                skanery = serialNumber,
                kod = kod,
                nazwa = nazwa,
                status = status,
                firma = firma
            )
            
            val jsonBody = gson.toJson(requestData)
            val requestBody = jsonBody.toRequestBody("application/json".toMediaType())
            
            val url = "$BASE_URL&arkusz=${sheetName}"
            val request = Request.Builder()
                .url(url)
                .post(requestBody)
                .build()
            
            val response = client.newCall(request).execute()
            val body = response.body?.string() ?: throw IOException("Empty response")
            
            gson.fromJson(body, ApiResponse::class.java)
        } catch (e: Exception) {
            ApiResponse(
                status = "BLAD",
                message = "Failed to update: ${e.message}"
            )
        }
    }
    
    /**
     * Insert a new item into Google Sheets
     * @param sheetName Sheet to insert into
     * @param item Item data to insert
     * @return API response
     */
    suspend fun insertItem(
        sheetName: String,
        item: GoogleSheetItem
    ): ApiResponse = withContext(Dispatchers.IO) {
        try {
            val requestData = ApiRequest(
                akcja = "insert",
                skanery = item.serialNumber,  // v1.24.17: Use serialNumber field
                kod = item.kod,
                nazwa = item.nazwa,
                status = item.status,
                firma = item.firma
            )
            
            val jsonBody = gson.toJson(requestData)
            val requestBody = jsonBody.toRequestBody("application/json".toMediaType())
            
            val url = "$BASE_URL&arkusz=${sheetName}"
            val request = Request.Builder()
                .url(url)
                .post(requestBody)
                .build()
            
            val response = client.newCall(request).execute()
            val body = response.body?.string() ?: throw IOException("Empty response")
            
            gson.fromJson(body, ApiResponse::class.java)
        } catch (e: Exception) {
            ApiResponse(
                status = "BLAD",
                message = "Failed to insert: ${e.message}"
            )
        }
    }
}
