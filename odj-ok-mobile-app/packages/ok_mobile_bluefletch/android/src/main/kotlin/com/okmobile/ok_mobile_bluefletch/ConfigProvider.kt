package com.okmobile.ok_mobile_bluefletch

import android.content.Context
import com.bluefletch.launcherprovider.LauncherProviderHelper

class BlueFletchConfigProvider(private val context: Context) {

    fun getDeviceId(): String? {
        return LauncherProviderHelper.getCurrentConfig(context).getExtAttr("deviceId")
    }
}
