import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_scanner/ok_mobile_scanner.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

part 'package:ok_mobile_counting_center/application/receivals_cubit.dart';
part 'package:ok_mobile_counting_center/application/receivals_state.dart';
part 'package:ok_mobile_counting_center/presentation/screens/cc_closed_bag_details_screen.dart';
part 'package:ok_mobile_counting_center/presentation/screens/cc_collected_receivals_screen.dart';
part 'package:ok_mobile_counting_center/presentation/screens/cc_package_receival_screen.dart';
part 'package:ok_mobile_counting_center/presentation/screens/cc_planned_receivals_screen.dart';
part 'package:ok_mobile_counting_center/presentation/screens/cc_receival_details_screen.dart';
part 'package:ok_mobile_counting_center/presentation/screens/cc_receival_uneditable_overview_screen.dart';
part 'package:ok_mobile_counting_center/presentation/screens/counting_center_main_screen.dart';

class OkMobileCountingCenterPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: CCPackageReceivalScreen.routeName,
      name: CCPackageReceivalScreen.routeName,
      builder: (context, state) => const CCPackageReceivalScreen(),
    ),
    GoRoute(
      path: CCPlannedReceivalsScreen.routeName,
      name: CCPlannedReceivalsScreen.routeName,
      builder: (context, state) => const CCPlannedReceivalsScreen(),
    ),
    GoRoute(
      path: CCCollectedReceivalsScreen.routeName,
      name: CCCollectedReceivalsScreen.routeName,
      builder: (context, state) => const CCCollectedReceivalsScreen(),
    ),
    GoRoute(
      path:
          '${ReceivalDetailsScreen.routeName}/:${ReceivalDetailsScreen.pickupIdParam}/:${ReceivalDetailsScreen.backRouteParam}',
      name: ReceivalDetailsScreen.routeName,
      builder:
          (context, state) => ReceivalDetailsScreen(
            pickupId:
                state.pathParameters[ReceivalDetailsScreen.pickupIdParam]!,
            backRoute:
                state.pathParameters[ReceivalDetailsScreen.backRouteParam]!,
          ),
    ),
    GoRoute(
      path: ReceivalUneditableOverviewScreen.routeName,
      name: ReceivalUneditableOverviewScreen.routeName,
      builder: (context, state) => const ReceivalUneditableOverviewScreen(),
    ),
    GoRoute(
      path:
          '${CCClosedBagDetailsScreen.routeName}/:${CCClosedBagDetailsScreen.selectedBagIdParam}',
      name: CCClosedBagDetailsScreen.routeName,
      builder: (context, state) {
        final hideManagementOptions =
            state.uri.queryParameters[CCClosedBagDetailsScreen
                .hideManagementOptionsParam] ==
            'true';
        final selectedBagId =
            state.pathParameters[CCClosedBagDetailsScreen.selectedBagIdParam];

        return CCClosedBagDetailsScreen(
          hideManagementOptions: hideManagementOptions,
          selectedBagId: selectedBagId!,
        );
      },
    ),
  ];
}
