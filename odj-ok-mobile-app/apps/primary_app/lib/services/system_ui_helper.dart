import 'dart:developer';

import 'package:flutter/services.dart';

class SystemUiHelper {
  static const platform = MethodChannel('system_ui');

  static Future<void> hideNavigationBar() async {
    try {
      await platform.invokeMethod('hideNavigationBar');
    } on PlatformException catch (e) {
      log("Failed to hide navigation bar: '${e.message}'.");
    }
  }
}
