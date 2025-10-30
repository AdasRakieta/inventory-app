import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
import 'package:ok_mobile_boxes/presentation/screens/closed_bag_details/add_bags_open_box_summary_screen.dart';
import 'package:ok_mobile_boxes/presentation/screens/closed_bag_details/change_label_closed_box_summary_screen.dart';
import 'package:ok_mobile_boxes/presentation/screens/closed_bag_details/change_label_open_box_summary_screen.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_scanner/ok_mobile_scanner.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

part 'package:ok_mobile_boxes/application/box_cubit.dart';
part 'package:ok_mobile_boxes/application/box_state.dart';
part 'package:ok_mobile_boxes/presentation/screens/add_bags_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/box_management_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/boxes_to_change_label_list_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/change_box_label_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/choose_open_box_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/close_boxes_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/closed_box_summary_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/confirm_box_closing_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/open_box_summary_screen.dart';
part 'package:ok_mobile_boxes/presentation/screens/open_new_box_screen.dart';
part 'package:ok_mobile_boxes/presentation/widgets/closed_box_button.dart';
part 'package:ok_mobile_boxes/presentation/widgets/closed_box_buttons_column.dart';
part 'package:ok_mobile_boxes/presentation/widgets/closed_box_card.dart';
part 'package:ok_mobile_boxes/presentation/widgets/open_box_button.dart';
part 'package:ok_mobile_boxes/presentation/widgets/open_box_buttons_column.dart';
part 'package:ok_mobile_boxes/presentation/widgets/open_box_card.dart';

class OkMobileBoxesPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: BoxManagementScreen.routeName,
      name: BoxManagementScreen.routeName,
      builder: (context, state) => const BoxManagementScreen(),
    ),
    GoRoute(
      path: OpenNewBoxScreen.routeName,
      name: OpenNewBoxScreen.routeName,
      builder: (context, state) => const OpenNewBoxScreen(),
    ),
    GoRoute(
      path: AddBagsScreen.routeName,
      name: AddBagsScreen.routeName,
      builder: (context, state) => const AddBagsScreen(),
    ),
    GoRoute(
      path: ChooseOpenBoxScreen.routeName,
      name: ChooseOpenBoxScreen.routeName,
      builder: (context, state) => const ChooseOpenBoxScreen(),
    ),
    GoRoute(
      path: OpenBoxSummaryScreen.routeName,
      name: OpenBoxSummaryScreen.routeName,
      builder: (context, state) {
        final backRoute =
            state.uri.queryParameters[OpenBoxSummaryScreen.backRouteParam];
        final readOnly =
            state.uri.queryParameters[OpenBoxSummaryScreen.readOnlyParam] ==
            'true';
        return OpenBoxSummaryScreen(
          backRoute: backRoute ?? BoxManagementScreen.routeName,
          readOnly: readOnly,
        );
      },
    ),
    GoRoute(
      path:
          '${ConfirmBoxClosingScreen.routeName}/:${ConfirmBoxClosingScreen.selectedBoxIdsParam}/:${ConfirmBoxClosingScreen.backRouteParam}',
      name: ConfirmBoxClosingScreen.routeName,
      builder: (context, state) {
        final itemsString =
            state.pathParameters[ConfirmBoxClosingScreen.selectedBoxIdsParam] ??
            '';
        final itemsList = itemsString.split(',');
        return ConfirmBoxClosingScreen(
          selectedBoxIds: itemsList,
          backRoute:
              state.pathParameters[ConfirmBoxClosingScreen.backRouteParam]!,
        );
      },
    ),
    GoRoute(
      path: ClosedBoxSummaryScreen.routeName,
      name: ClosedBoxSummaryScreen.routeName,
      builder: (context, state) {
        final backRoute =
            state.uri.queryParameters[ClosedBoxSummaryScreen.backRouteParam];
        final readOnly =
            state.uri.queryParameters[ClosedBoxSummaryScreen.readOnlyParam] ==
            'true';

        return ClosedBoxSummaryScreen(
          backRoute: backRoute ?? BoxManagementScreen.routeName,
          readOnly: readOnly,
        );
      },
    ),
    GoRoute(
      path: CloseBoxesScreen.routeName,
      name: CloseBoxesScreen.routeName,
      builder: (context, state) => const CloseBoxesScreen(),
    ),
    GoRoute(
      path: BoxesToChangeLabelListScreen.routeName,
      name: BoxesToChangeLabelListScreen.routeName,
      builder: (context, state) => const BoxesToChangeLabelListScreen(),
    ),
    GoRoute(
      path: ChangeBoxLabelScreen.routeName,
      name: ChangeBoxLabelScreen.routeName,
      builder: (context, state) => const ChangeBoxLabelScreen(),
    ),
    GoRoute(
      path: AddBagsOpenBoxSummaryScreen.routeName,
      name: AddBagsOpenBoxSummaryScreen.routeName,
      builder: (context, state) => const AddBagsOpenBoxSummaryScreen(),
    ),
    GoRoute(
      path: ChangeLabelOpenBoxSummaryScreen.routeName,
      name: ChangeLabelOpenBoxSummaryScreen.routeName,
      builder: (context, state) => const ChangeLabelOpenBoxSummaryScreen(),
    ),
    GoRoute(
      path: ChangeLabelClosedBoxSummaryScreen.routeName,
      name: ChangeLabelClosedBoxSummaryScreen.routeName,
      builder: (context, state) => const ChangeLabelClosedBoxSummaryScreen(),
    ),
  ];
}
