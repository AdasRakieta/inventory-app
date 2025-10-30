import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';

class GlobalOverlayService {
  GlobalOverlayService.showLoader(
    BuildContext context, {
    required AuthStatus authStatus,
    required List<BaseState> appStates,
  }) {
    if (authStatus == AuthStatus.loading ||
        authStatus == AuthStatus.authenticatedLoading ||
        appStates.any((state) => state.generalState == GeneralState.loading)) {
      context.loaderOverlay.show();
    } else {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }
    }
  }

  GlobalOverlayService.showSnackBar(
    GlobalKey<ScaffoldMessengerState> scaffoldKey, {
    required AuthCubit authCubit,
    required List<ISnackBarCubit> cubits,
  }) {
    if (authCubit.state.result is Failure) {
      SnackBarHelper.showFailureSnackBar(
        scaffoldKey,
        authCubit.state.result! as Failure,
      );
      authCubit.clearResult();
    }

    final toShow = cubits.map((cubit) {
      if (cubit.state.resultObject != null) {
        return cubit;
      }
    });
    if (toShow.isNotEmpty) {
      for (final cubit in toShow) {
        if (cubit?.state.resultObject is Failure) {
          SnackBarHelper.showFailureSnackBar(
            scaffoldKey,
            cubit!.state.resultObject! as Failure,
          );
          cubit.clearResult();
        }

        if (cubit?.state.resultObject is Success) {
          SnackBarHelper.showSuccessSnackBar(
            scaffoldKey,
            cubit!.state.resultObject! as Success,
          );
          cubit.clearResult();
        }
      }
    }
  }
}
