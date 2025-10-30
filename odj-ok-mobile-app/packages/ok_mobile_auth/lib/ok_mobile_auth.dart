import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

part 'package:ok_mobile_auth/application/auth_cubit.dart';
part 'package:ok_mobile_auth/application/auth_state.dart';
part 'package:ok_mobile_auth/application/user_cubit.dart';
part 'package:ok_mobile_auth/application/user_state.dart';
part 'package:ok_mobile_auth/helpers/logout_helper.dart';
part 'package:ok_mobile_auth/presentation/screens/login_screen.dart';
part 'package:ok_mobile_auth/presentation/screens/ok_splash_screen.dart';
part 'package:ok_mobile_auth/presentation/screens/in_app_auth_screen.dart';

class OkMobileAuthPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: LoginScreen.routeName,
      name: LoginScreen.routeName,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: OkSplashScreen.routeName,
      name: OkSplashScreen.routeName,
      builder: (context, state) => const OkSplashScreen(),
    ),
    GoRoute(
      path: InAppAuthScreen.routeName,
      name: InAppAuthScreen.routeName,
      builder: (context, state) => const InAppAuthScreen(),
    ),
  ];
}
