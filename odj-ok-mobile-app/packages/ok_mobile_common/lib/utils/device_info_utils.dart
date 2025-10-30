import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

enum AllowedDeviceModel {
  zebraTc58e('tc58e'),
  zebraTc57('tc57');

  const AllowedDeviceModel(this.model);

  final String model;

  static bool isAllowedDevice(String deviceModel) => AllowedDeviceModel.values
      .any((e) => deviceModel.toLowerCase().contains(e.model));
}

class DeviceInfoUtils {
  Future<bool> _isSecuredRun() async {
    if (!kReleaseMode) return true;

    if (await RootCheckerPlus.isRootChecker() ?? false) return false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    return androidInfo.isPhysicalDevice &&
        AllowedDeviceModel.isAllowedDevice(androidInfo.model.toLowerCase());
  }

  Future<void> runSecurityChecksOrExit() async {
    final isSecuredRun = await _isSecuredRun();

    if (isSecuredRun) return;

    exit(0);
  }
}
