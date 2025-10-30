import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
// import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';// TODO enable boxes when ready
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_scanner/ok_mobile_scanner.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

part 'package:ok_mobile_bags/application/bags_cubit.dart';
part 'package:ok_mobile_bags/application/bags_state.dart';
part 'package:ok_mobile_bags/presentation/screens/bags_management_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/bags_to_add_to_box_list_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/bags_to_change_label_list_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/bags_to_change_seal_list_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/bags_to_close_and_add_seal_list_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/change_bag_label_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/change_bag_seal_screen.dart';
// part 'package:ok_mobile_bags/presentation/screens/choose_box_screen.dart';// TODO enable boxes when ready
// part 'package:ok_mobile_bags/presentation/screens/chosen_bags_to_add_to_box_screen.dart';// TODO enable boxes when ready
part 'package:ok_mobile_bags/presentation/screens/close_and_seal_bag_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/closed_bag_details_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/closed_bags_list_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/open_bag_details_screen.dart';
part 'package:ok_mobile_bags/presentation/screens/seal_added_details_screen.dart';
part 'package:ok_mobile_bags/presentation/widgets/closable_bag_buttons_list.dart';
part 'package:ok_mobile_bags/presentation/widgets/open_buttons_column.dart';
part 'package:ok_mobile_bags/presentation/widgets/package_info_card.dart';

class OkMobileBagsPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: BagsManagementScreen.routeName,
      name: BagsManagementScreen.routeName,
      builder: (context, state) => const BagsManagementScreen(),
    ),
    GoRoute(
      path:
          '${OpenBagDetailsScreen.routeName}/:${OpenBagDetailsScreen.closeBagParam}/:${OpenBagDetailsScreen.selectedBagIdParam}',
      name: OpenBagDetailsScreen.routeName,
      builder: (context, state) {
        final showCloseBagButton =
            state.pathParameters[OpenBagDetailsScreen.closeBagParam] == 'true';
        final selectedBagId =
            state.pathParameters[OpenBagDetailsScreen.selectedBagIdParam];
        final openedFromReturns =
            state.uri.queryParameters[OpenBagDetailsScreen
                .openedFromReturnsParam] ==
            'true';
        return OpenBagDetailsScreen(
          showCloseBagButton: showCloseBagButton,
          selectedBagId: selectedBagId!,
          openedFromReturns: openedFromReturns,
        );
      },
    ),
    GoRoute(
      path:
          '${ClosedBagDetailsScreen.routeName}/:${ClosedBagDetailsScreen.selectedBagIdParam}',
      name: ClosedBagDetailsScreen.routeName,
      builder: (context, state) {
        final hideManagementOptions =
            state.uri.queryParameters[ClosedBagDetailsScreen
                .hideManagementOptionsParam] ==
            'true';
        final selectedBagId =
            state.pathParameters[ClosedBagDetailsScreen.selectedBagIdParam];

        return ClosedBagDetailsScreen(
          hideManagementOptions: hideManagementOptions,
          selectedBagId: selectedBagId!,
        );
      },
    ),
    GoRoute(
      path: BagsToChangeLabelListScreen.routeName,
      name: BagsToChangeLabelListScreen.routeName,
      builder: (context, state) => const BagsToChangeLabelListScreen(),
    ),
    GoRoute(
      path: ChangeBagLabelScreen.routeName,
      name: ChangeBagLabelScreen.routeName,
      builder: (context, state) => const ChangeBagLabelScreen(),
    ),
    GoRoute(
      path: BagsToCloseAndAddSealListScreen.routeName,
      name: BagsToCloseAndAddSealListScreen.routeName,
      builder: (context, state) => const BagsToCloseAndAddSealListScreen(),
    ),
    GoRoute(
      path: BagsToChangeSealListScreen.routeName,
      name: BagsToChangeSealListScreen.routeName,
      builder: (context, state) => const BagsToChangeSealListScreen(),
    ),
    GoRoute(
      path: CloseAndSealBagScreen.routeName,
      name: CloseAndSealBagScreen.routeName,
      builder: (context, state) {
        final openedFromReturns =
            state.uri.queryParameters[CloseAndSealBagScreen
                .openedFromReturnsParam] ==
            'true';
        return CloseAndSealBagScreen(openedFromReturns: openedFromReturns);
      },
    ),
    GoRoute(
      path: ChangeBagSealScreen.routeName,
      name: ChangeBagSealScreen.routeName,
      builder: (context, state) => const ChangeBagSealScreen(),
    ),
    GoRoute(
      path: SealAddedDetailsScreen.routeName,
      name: SealAddedDetailsScreen.routeName,
      builder: (context, state) {
        final openedFromReturns =
            state.uri.queryParameters[SealAddedDetailsScreen
                .openedFromReturnsParam] ==
            'true';
        final showCloseAnotherBagButton =
            state.uri.queryParameters[SealAddedDetailsScreen
                .showCloseAnotherBagButtonParam] ==
            'true';
        return SealAddedDetailsScreen(
          openedFromReturns: openedFromReturns,
          showCloseAnotherBagButton: showCloseAnotherBagButton,
        );
      },
    ),
    GoRoute(
      path: BagsToAddToBoxListScreen.routeName,
      name: BagsToAddToBoxListScreen.routeName,
      builder: (context, state) => const BagsToAddToBoxListScreen(),
    ),
    // TODO enable boxes when ready
    // GoRoute(
    //   path: ChooseBoxScreen.routeName,
    //   name: ChooseBoxScreen.routeName,
    //   builder: (context, state) => ChooseBoxScreen(
    //     singleBagMode:
    // ignore: lines_longer_than_80_chars
    //         state.uri.queryParameters[ChooseBoxScreen.singleBagModeParam] ==
    //             'true',
    //   ),
    // ),
    // GoRoute(
    //   path: ChosenBagsToAddToBoxScreen.routeName,
    //   name: ChosenBagsToAddToBoxScreen.routeName,
    //   builder: (context, state) => const ChosenBagsToAddToBoxScreen(),
    // ),
    GoRoute(
      path: ClosedBagsListScreen.routeName,
      name: ClosedBagsListScreen.routeName,
      builder: (context, state) => const ClosedBagsListScreen(),
    ),
  ];
}
