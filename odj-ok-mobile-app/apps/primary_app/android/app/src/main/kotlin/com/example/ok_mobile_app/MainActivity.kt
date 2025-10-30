package com.example.ok_mobile_app

import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val systemUiMethodChannel = "system_ui"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val uiChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, systemUiMethodChannel)
        uiChannel.setMethodCallHandler {
            call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "hideNavigationBar" -> {
                    hideNavigationBar()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hideNavigationBar() {
        window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
    }
}
