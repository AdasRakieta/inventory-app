package com.example.ok_mobile_imei

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.net.Uri
import androidx.core.net.toUri

/** OkMobileImeiPlugin */
class OkMobileImeiPlugin: FlutterPlugin, MethodCallHandler {
  companion object {
        const val IMEI_SERVICE_IDENTIFIER = "content://oem_info/wan/imei"
        const val SERIAL_SERVICE_IDENTIFIER = "content://oem_info/oem.zebra.secure/build_serial"
  }


  private lateinit var channel : MethodChannel
  private lateinit var appContext: Context


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "oem_info")
    channel.setMethodCallHandler(this)
    appContext = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
        "getDeviceImei" -> {
            try {
                result.success(getOemInfo(IMEI_SERVICE_IDENTIFIER.toUri()))
            } catch (e: Exception){
                result.error("1", "Failed to get device IMEI", e.localizedMessage)
            }
        }
        "getDeviceSerial" -> {
            try {
                result.success(getOemInfo(SERIAL_SERVICE_IDENTIFIER.toUri()))
            } catch (e: Exception){
                result.error("1", "Failed to get device Serial", e.localizedMessage)
            }
        }
    }
  }

  private fun getOemInfo(serviceUri: Uri): String {
    val cursor = appContext.contentResolver.query(serviceUri, null, null, null, null)
    if (cursor == null || cursor.count < 1) {
        throw Exception("Error: This app does not have access to call OEM service. " +
                "Please assign access to " + serviceUri + " through MX.")
    }
    while (cursor.moveToNext()) {
        if (cursor.columnCount == 0) {
            throw Exception("Error: $serviceUri does not exist on this device")
        } else {
            return cursor.getString(0)
        }
    }
    cursor.close()
    return ""
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
