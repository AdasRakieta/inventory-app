part of '../../../ok_mobile_auth.dart';

class LogoutHelper {
  static Future<void> onLogoutCleanup(BuildContext context) async {
    context.read<DeviceConfigCubit>().clear();
    await context.read<ReturnsCubit>().removeCache();
  }
}
