package com.example.inventoryapp.utils

import android.app.AlertDialog
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.widget.EditText
import android.widget.ImageView
import android.widget.Toast
import androidx.fragment.app.FragmentActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * Helper to show a QR for given text and optionally print via Bluetooth.
 */
object QrShareHelper {

    fun showQrOrPrint(activity: FragmentActivity, text: String) {
        val qr: Bitmap = QRCodeGenerator.generateQRCode(text, width = 512, height = 512)
            ?: run {
                Toast.makeText(activity, "Failed to generate QR", Toast.LENGTH_SHORT).show()
                return
            }

        val imageView = ImageView(activity).apply { setImageBitmap(qr) }

        AlertDialog.Builder(activity)
            .setTitle("Export via QR")
            .setView(imageView)
            .setPositiveButton("Copy JSON") { d, _ ->
                val cm = activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                cm.setPrimaryClip(ClipData.newPlainText("export-json", text))
                Toast.makeText(activity, "Copied to clipboard", Toast.LENGTH_SHORT).show()
                d.dismiss()
            }
            .setNeutralButton("Print QR") { d, _ ->
                d.dismiss()
                promptAndPrint(activity, qr)
            }
            .setNegativeButton("Close", null)
            .show()
    }

    private fun promptAndPrint(activity: FragmentActivity, qr: Bitmap) {
        val input = EditText(activity).apply { hint = "Printer MAC (e.g. 00:11:22:33:44:55)" }
        AlertDialog.Builder(activity)
            .setTitle("Bluetooth printer MAC")
            .setView(input)
            .setPositiveButton("Print") { d, _ ->
                val mac = input.text?.toString()?.trim().orEmpty()
                if (mac.isEmpty()) {
                    Toast.makeText(activity, "MAC is required", Toast.LENGTH_SHORT).show()
                } else {
                    // Launch printing off the UI thread
                    CoroutineScope(Dispatchers.Main).launch {
                        val socket = BluetoothPrinterHelper.connectToPrinter(mac)
                        if (socket == null) {
                            Toast.makeText(activity, "Failed to connect", Toast.LENGTH_SHORT).show()
                            return@launch
                        }
                        val ok = BluetoothPrinterHelper.printQRCode(socket, qr, headerText = "Inventory Export")
                        BluetoothPrinterHelper.disconnect(socket)
                        Toast.makeText(activity, if (ok) "Printed" else "Print failed", Toast.LENGTH_SHORT).show()
                    }
                }
                d.dismiss()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
