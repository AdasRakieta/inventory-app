import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:ok_mobile_admin/ok_mobile_admin.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
// import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';// TODO enable boxes when ready
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_scanner/ok_mobile_scanner.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';
import 'package:ok_mobile_zebra_printer/ok_mobile_zebra_printer.dart';

part 'package:ok_mobile_pickups/application/pickups_cubit.dart';
part 'package:ok_mobile_pickups/application/pickups_state.dart';
part 'package:ok_mobile_pickups/presentation/screens/driver_pickup_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickup_closed_bag_details_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickup_confirmation_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickup_details_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickup_overview_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickup_uneditable_overview_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickups_list_screen.dart';
part 'package:ok_mobile_pickups/presentation/screens/pickups_management_screen.dart';

class OkMobilePickupsPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: PickupsManagementScreen.routeName,
      name: PickupsManagementScreen.routeName,
      builder: (context, state) => const PickupsManagementScreen(),
    ),
    GoRoute(
      path: DriverPickupScreen.routeName,
      name: DriverPickupScreen.routeName,
      builder: (context, state) => const DriverPickupScreen(),
    ),
    GoRoute(
      path:
          '${PickupOverviewScreen.routeName}/:${PickupOverviewScreen.backRouteParam}',
      name: PickupOverviewScreen.routeName,
      builder: (context, state) => PickupOverviewScreen(
        backRoute: state.pathParameters[PickupOverviewScreen.backRouteParam]!,
      ),
    ),
    GoRoute(
      path: PickupConfirmationScreen.routeName,
      name: PickupConfirmationScreen.routeName,
      builder: (context, state) => const PickupConfirmationScreen(),
    ),
    GoRoute(
      path: PickupsListScreen.routeName,
      name: PickupsListScreen.routeName,
      builder: (context, state) => const PickupsListScreen(),
    ),
    GoRoute(
      path:
          '${PickupDetailsScreen.routeName}/:${PickupDetailsScreen.pickupIdParam}',
      name: PickupDetailsScreen.routeName,
      builder: (context, state) => PickupDetailsScreen(
        pickupId: state.pathParameters[PickupDetailsScreen.pickupIdParam]!,
      ),
    ),
    GoRoute(
      path: PickupUneditableOverviewScreen.routeName,
      name: PickupUneditableOverviewScreen.routeName,
      builder: (context, state) => const PickupUneditableOverviewScreen(),
    ),
    GoRoute(
      path:
          '${PickupClosedBagDetailsScreen.routeName}/:${PickupClosedBagDetailsScreen.selectedBagIdParam}',
      name: PickupClosedBagDetailsScreen.routeName,
      builder: (context, state) {
        final hideManagementOptions =
            state.uri.queryParameters[PickupClosedBagDetailsScreen
                .hideManagementOptionsParam] ==
            'true';
        final selectedBagId = state
            .pathParameters[PickupClosedBagDetailsScreen.selectedBagIdParam];

        return PickupClosedBagDetailsScreen(
          hideManagementOptions: hideManagementOptions,
          selectedBagId: selectedBagId!,
        );
      },
    ),
  ];
}
