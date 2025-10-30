package com.okmobile.ok_mobile_bluefletch

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class OkMobileBluefletchPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private var configProvider: BlueFletchConfigProvider? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context: Context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "ok_mobile_bluefletch")
        methodChannel.setMethodCallHandler(this)
        configProvider = BlueFletchConfigProvider(context)
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceId" -> {
                try {
                    val deviceId = configProvider?.getDeviceId()
                    if (deviceId != null) {
                        result.success(deviceId)
                    } else {
                        result.error("DEVICE_ID_ERROR", "Device ID is null or unavailable", null)
                    }
                } catch (e: Exception) {
                    result.error("DEVICE_ID_ERROR", "Failed to get device ID", e.localizedMessage)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        configProvider = null
    }
}
