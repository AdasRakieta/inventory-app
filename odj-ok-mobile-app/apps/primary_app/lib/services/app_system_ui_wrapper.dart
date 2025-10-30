import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ok_mobile_app/services/system_ui_helper.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

// without this widget, the status bar icons become black after navigation
// events (and we want them to be light)
class AppSystemUiWrapper extends StatelessWidget {
  const AppSystemUiWrapper({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    SystemUiHelper.hideNavigationBar();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: child,
    );
  }
}
