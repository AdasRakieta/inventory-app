import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_scanner/ok_mobile_scanner.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

part 'application/admin_cubit.dart';
part 'application/admin_state.dart';
part 'presentation/screens/printer_config_screen.dart';
part 'presentation/screens/printer_not_configured_screen.dart';
part 'presentation/screens/settings_main_screen.dart';
part 'presentation/widgets/language_buttons.dart';

class OkMobileAdminPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: SettingsMainScreen.routeName,
      name: SettingsMainScreen.routeName,
      builder: (context, state) => const SettingsMainScreen(),
    ),
    GoRoute(
      path: PrinterConfigScreen.routeName,
      name: PrinterConfigScreen.routeName,
      builder: (context, state) {
        final nextRoute =
            state.uri.queryParameters[PrinterConfigScreen.nextRouteParam];
        return PrinterConfigScreen(nextRoute: nextRoute);
      },
    ),
    GoRoute(
      path: PrinterNotConfiguredScreen.routeName,
      name: PrinterNotConfiguredScreen.routeName,
      builder: (context, state) {
        final finalRoute = state
            .uri
            .queryParameters[PrinterNotConfiguredScreen.finalRouteParam]!;
        final subtitle = state
            .uri
            .queryParameters[PrinterNotConfiguredScreen.subtitleParam]!;
        return PrinterNotConfiguredScreen(
          finalRoute: finalRoute,
          subtitle: subtitle,
        );
      },
    ),
  ];
}
