import 'package:flutter/services.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

class OkMobileBluefletch {
  static const _channel = MethodChannel('ok_mobile_bluefletch');

  Future<String?> getDeviceId() async {
    try {
      final deviceId = await _channel.invokeMethod<String>('getDeviceId');
      if (deviceId != null && deviceId.isNotEmpty) {
        return deviceId;
      }
      return null;
    } on PlatformException catch (error) {
      LoggerService().trackError(error);
      return null;
    } catch (error) {
      LoggerService().trackError(error);
      return null;
    }
  }
}
