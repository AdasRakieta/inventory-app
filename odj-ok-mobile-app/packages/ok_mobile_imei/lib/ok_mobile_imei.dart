import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_common/utils/test_utils.dart';

class OkMobileImei {
  static const oemInfoMethodChannel = "oem_info";
  static const deviceImeiMethodCall = "getDeviceImei";
  static const deviceSerialMethodCall = "getDeviceSerial";

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(oemInfoMethodChannel);

  Future<String?> getDeviceImei() async {
    try {
      return await methodChannel.invokeMethod<String>(deviceImeiMethodCall);
    } catch (error, stackTrace) {
      if (!isTestExecution) {
        LoggerService().trackError(error, stackTrace: stackTrace);
      }
      return null;
    }
  }

  Future<String?> getDeviceSerial() async {
    try {
      return await methodChannel.invokeMethod<String>(deviceSerialMethodCall);
    } catch (error, stackTrace) {
      if (!isTestExecution) {
        LoggerService().trackError(error, stackTrace: stackTrace);
      }
      return null;
    }
  }
}
