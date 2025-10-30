import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ok_mobile_app/di/di.dart';
import 'package:ok_mobile_app/services/app_bloc_observer.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_common/utils/device_info_utils.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    log(
      'FlutterError: ${details.exceptionAsString()}',
      stackTrace: details.stack,
    );
    LoggerService().trackError(
      details.exception,
      stackTrace: details.stack,
      isFatal: true,
      properties: {'flutter_error': details.toString()},
    );
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await DeviceInfoUtils().runSecurityChecksOrExit();

      final config = AppConfigProvider();

      configureAllPackagesDependencies(env: config.environment.name);

      // Request external storage permission early
      await PermissionService().requestExternalStoragePermission();

      await MasterDataDatabase().initDatabase(config.environment.name);

      // Uncomment if needed to erase all local data
      // await MasterDataDatabase().deleteDatabaseUtil(environment.name);
      // await PreferencesHelper().clearMasterDataCheckedToday();

      Bloc.observer = AppBlocObserver();
      await LoggerService().create(4);

      runApp(await builder());
    },
    (error, stack) {
      log(error.toString(), stackTrace: stack);
      LoggerService().trackError(error, stackTrace: stack, isFatal: true);
    },
  );
}
