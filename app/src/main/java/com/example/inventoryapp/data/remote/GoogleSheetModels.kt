package com.example.inventoryapp.data.remote

import com.google.gson.annotations.SerializedName

/**
 * Represents a single row from Google Sheets API response
 * Maps actual Polish field names from the API
 * 
 * Package Sync Mapping:
 * - Kod → Package name (products grouped by this field)
 * - Serial Number Field → Product serial number (unique product identifier)
 *   - "Skanery" for scanner sheets
 *   - "Drukarki" for printer sheet
 *   - "Stacje do drukarek" for printer docking station sheet
 *   - "Stacje dokujące" for scanner docking station sheet
 * - Status → Package status (mapped to PackageEntity status)
 * - Nazwa + sheet name → Package description
 * 
 * v1.24.17: Added alternate field names for serial numbers to support all 5 sheet types
 */
data class GoogleSheetItem(
    @SerializedName("Urządzenie") val urzadzenie: String? = null,   // Device type (e.g., "Skaner TC58E")
    @SerializedName(value = "Skanery", alternate = ["Drukarki", "Stacje do drukarek", "Stacje dokujące"])
    val serialNumber: String,                                        // Product serial number (multi-sheet compatible)
    @SerializedName("Status") val status: String? = null,           // Package status (e.g., "Wydano", "Magazyn")
    @SerializedName("Kod") val kod: String? = null,                 // PACKAGE NAME (group identifier)
    @SerializedName("Nazwa") val nazwa: String? = null,             // Location/store name for description
    @SerializedName("Data wydania") val dataWydania: String? = null,// Issue date
    @SerializedName("Data zwrotu") val dataZwrotu: String? = null,  // Return date
    @SerializedName("Firma") val firma: String? = null,             // Company name
    @SerializedName("Komentarz") val komentarz: String? = null      // Comments
)

/**
 * API response wrapper from Google Apps Script
 */
data class ApiResponse(
    val status: String,   // "SUKCES" or "BLAD"
    val message: String   // Success/error message
)

/**
 * Request body for POST operations (update/insert)
 * Uses actual API field names
 */
data class ApiRequest(
    val akcja: String,            // "update" or "insert"
    val skanery: String,          // Serial number (UNIQUE ID)
    val kod: String? = null,      // Store/location code
    val nazwa: String? = null,    // Store/location name
    val status: String? = null,   // Status
    val firma: String? = null     // Company
)
