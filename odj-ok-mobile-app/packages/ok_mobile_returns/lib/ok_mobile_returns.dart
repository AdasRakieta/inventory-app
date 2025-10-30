import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:ok_mobile_admin/ok_mobile_admin.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_counting_center/ok_mobile_counting_center.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_pickups/ok_mobile_pickups.dart';
import 'package:ok_mobile_scanner/ok_mobile_scanner.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';
import 'package:ok_mobile_zebra_printer/ok_mobile_zebra_printer.dart';

part 'package:ok_mobile_returns/application/masterdata_cubit.dart';
part 'package:ok_mobile_returns/application/masterdata_state.dart';
part 'package:ok_mobile_returns/application/returns_cubit.dart';
part 'package:ok_mobile_returns/application/returns_state.dart';
part 'package:ok_mobile_returns/presentation/screens/admin_healthcheck_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/archive_closed_return_summary_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/archive_confirm_voucher_print_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/bag_scanner_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/choose_bag_type_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/closed_return_summary_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/closed_returns_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/confirm_voucher_print_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/finish_return_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/main_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/main_screens/collection_point_main_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/main_screens/main_screen_error_card.dart';
part 'package:ok_mobile_returns/presentation/screens/package_scanner_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/return_details_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/return_summary_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/returns_archive_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/select_open_bag_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/success_return_summary_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/terms_and_conditions_screen.dart';
part 'package:ok_mobile_returns/presentation/screens/voucher_display_screen.dart';
part 'package:ok_mobile_returns/presentation/widgets/packages_summary_list.dart';
part 'package:ok_mobile_returns/presentation/widgets/return_button.dart';

class OkMobileReturnsPackageRoutes {
  static List<GoRoute> get routes => [
    GoRoute(
      path: TermsAndConditionsScreen.routeName,
      name: TermsAndConditionsScreen.routeName,
      builder: (context, state) => const TermsAndConditionsScreen(),
    ),
    GoRoute(
      path: MainScreen.routeName,
      name: MainScreen.routeName,
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: ChooseBagTypeScreen.routeName,
      name: ChooseBagTypeScreen.routeName,
      builder: (context, state) => ChooseBagTypeScreen(
        bagType: BagType.values.firstWhereOrNull(
          (e) =>
              e.name ==
              state.uri.queryParameters[ChooseBagTypeScreen.bagTypeParam],
        ),
        clearLastPackage:
            state.uri.queryParameters[ChooseBagTypeScreen
                .clearLastPackageParam] !=
            'false',
      ),
    ),
    GoRoute(
      path: ClosedReturnsScreen.routeName,
      name: ClosedReturnsScreen.routeName,
      builder: (context, state) {
        final shouldClearFiltersParamValue =
            state.uri.queryParameters[ClosedReturnsScreen
                .shouldClearFiltersParam] !=
            'false';
        return ClosedReturnsScreen(
          shouldClearFilters: shouldClearFiltersParamValue,
        );
      },
    ),
    GoRoute(
      path: ReturnsArchiveScreen.routeName,
      name: ReturnsArchiveScreen.routeName,
      builder: (context, state) {
        final shouldClearFiltersParamValue =
            state.uri.queryParameters[ReturnsArchiveScreen
                .shouldClearFiltersParam] !=
            'false';
        return ReturnsArchiveScreen(
          shouldClearFilters: shouldClearFiltersParamValue,
        );
      },
    ),
    GoRoute(
      path:
          '${ReturnDetailsScreen.routeName}/:${ReturnDetailsScreen.backRouteParam}',
      name: ReturnDetailsScreen.routeName,
      builder: (context, state) {
        return ReturnDetailsScreen(
          backRoute: state.pathParameters[ReturnDetailsScreen.backRouteParam],
          pathParameters: state.extra != null
              ? state.extra! as Map<String, String>
              : null,
        );
      },
    ),
    GoRoute(
      path: FinishReturnScreen.routeName,
      name: FinishReturnScreen.routeName,
      builder: (context, state) => const FinishReturnScreen(),
    ),
    GoRoute(
      path: '${BagScannerScreen.routeName}/:${BagScannerScreen.typeParam}',
      name: BagScannerScreen.routeName,
      builder: (context, state) {
        return BagScannerScreen(
          type: BagType.values.byName(
            state.pathParameters[BagScannerScreen.typeParam]!,
          ),
          clearLastPackage:
              state.uri.queryParameters[ChooseBagTypeScreen
                  .clearLastPackageParam] ==
              'true',
        );
      },
    ),
    GoRoute(
      path:
          '${ReturnSummaryScreen.routeName}/:${ReturnSummaryScreen.currentReturnIdParam}',
      name: ReturnSummaryScreen.routeName,
      builder: (context, state) => ReturnSummaryScreen(
        selectedReturnId:
            state.pathParameters[ReturnSummaryScreen.currentReturnIdParam]!,
      ),
    ),
    GoRoute(
      path:
          '${SuccessReturnSummaryScreen.routeName}/:${SuccessReturnSummaryScreen.currentReturnIdParam}',
      name: SuccessReturnSummaryScreen.routeName,
      builder: (context, state) => SuccessReturnSummaryScreen(
        selectedReturnId: state
            .pathParameters[SuccessReturnSummaryScreen.currentReturnIdParam]!,
      ),
    ),
    GoRoute(
      path:
          '${ClosedReturnSummaryScreen.routeName}/:${ClosedReturnSummaryScreen.currentReturnIdParam}/:${ClosedReturnSummaryScreen.shouldShowBackButtonParam}',
      name: ClosedReturnSummaryScreen.routeName,
      builder: (context, state) => ClosedReturnSummaryScreen(
        showBackButton:
            state.pathParameters[ClosedReturnSummaryScreen
                .shouldShowBackButtonParam] ==
            'true',
        selectedReturnId: state
            .pathParameters[ClosedReturnSummaryScreen.currentReturnIdParam]!,
      ),
    ),

    GoRoute(
      path:
          '${ArchiveClosedReturnSummaryScreen.routeName}/:${ArchiveClosedReturnSummaryScreen.currentReturnIdParam}',
      name: ArchiveClosedReturnSummaryScreen.routeName,
      builder: (context, state) => ArchiveClosedReturnSummaryScreen(
        selectedReturnId:
            state.pathParameters[ArchiveClosedReturnSummaryScreen
                .currentReturnIdParam]!,
      ),
    ),
    GoRoute(
      path:
          '${ConfirmVoucherPrintScreen.routeName}/:${ConfirmVoucherPrintScreen.currentReturnIdParam}',
      name: ConfirmVoucherPrintScreen.routeName,
      builder: (context, state) => ConfirmVoucherPrintScreen(
        selectedReturnId: state
            .pathParameters[ConfirmVoucherPrintScreen.currentReturnIdParam]!,
      ),
    ),
    GoRoute(
      path:
          '${ArchiveConfirmVoucherPrintScreen.routeName}/:${ArchiveConfirmVoucherPrintScreen.currentReturnIdParam}',
      name: ArchiveConfirmVoucherPrintScreen.routeName,
      builder: (context, state) => ArchiveConfirmVoucherPrintScreen(
        selectedReturnId:
            state.pathParameters[ArchiveConfirmVoucherPrintScreen
                .currentReturnIdParam]!,
      ),
    ),
    GoRoute(
      path: PackageScannerScreen.routeName,
      name: PackageScannerScreen.routeName,
      builder: (context, state) => const PackageScannerScreen(),
    ),
    GoRoute(
      path: SelectOpenBagScreen.routeName,
      name: SelectOpenBagScreen.routeName,
      builder: (context, state) {
        return SelectOpenBagScreen(
          type: BagType.values.byName(
            state.uri.queryParameters[SelectOpenBagScreen.typeParam]!,
          ),
          backRoute:
              state.uri.queryParameters[SelectOpenBagScreen.backRouteParam] ??
              '',
          clearLastPackage:
              state.uri.queryParameters[ChooseBagTypeScreen
                  .clearLastPackageParam] !=
              'false',
        );
      },
    ),
    GoRoute(
      path:
          '${VoucherDisplayScreen.routeName}/:${VoucherDisplayScreen.selectedReturnIdParam}',
      name: VoucherDisplayScreen.routeName,
      builder: (context, state) {
        return VoucherDisplayScreen(
          selectedReturnId:
              state.pathParameters[VoucherDisplayScreen.selectedReturnIdParam]!,
          isFirstTimeDisplayed:
              state.uri.queryParameters[VoucherDisplayScreen
                  .isFirstTimeDisplayedParam] ==
              'true',
        );
      },
    ),
  ];
}
