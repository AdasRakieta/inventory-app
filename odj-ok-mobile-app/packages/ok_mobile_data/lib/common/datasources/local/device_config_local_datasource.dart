/// On line 35 JSON parsing throws an Error which triggers the linter
/// Exception type is not working for this catch clause, moreover
/// There is no difference what went wrong during parsing
/// the handling is the same
// ignore_for_file: avoid_catches_without_on_clauses

part of '../../../ok_mobile_data.dart';

@injectable
class DeviceConfigDatasource {
  static const _mobileConfigStorageKey = 'mobile_device_config';

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  FlutterSecureStorage get _secureStorage =>
      FlutterSecureStorage(aOptions: _getAndroidOptions());

  String resolveFileName() {
    switch (getIt<AppConfigProvider>().environment) {
      case AppEnvironmentEnum.dev:
        return 'OKConfig.dev.json';
      case AppEnvironmentEnum.tst:
        return 'OKConfig.tst.json';
      case AppEnvironmentEnum.uat:
        return 'OKConfig.uat.json';
      case AppEnvironmentEnum.prd:
        return 'OKConfig.json';
      case AppEnvironmentEnum.offline:
        return '';
    }
  }

  Future<void> cacheMobileDeviceConfig(MobileDeviceConfig config) async {
    try {
      final jsonString = jsonEncode(config.toJson());
      await _secureStorage.write(
        key: _mobileConfigStorageKey,
        value: jsonString,
      );
    } catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);
      throw Exception('Failed to save MobileDeviceConfig');
    }
  }

  Future<MobileDeviceConfig?> readMobileDeviceConfigFromCache() async {
    try {
      final jsonString = await _secureStorage.read(
        key: _mobileConfigStorageKey,
      );
      if (jsonString == null) return null;
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return MobileDeviceConfig.fromJson(jsonMap);
    } catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> clearMobileDeviceConfigCache() async {
    try {
      await _secureStorage.delete(key: _mobileConfigStorageKey);
    } catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);
    }
  }

  Future<DeviceConfig?> getSotiDeviceConfig(String configFilePath) async {
    try {
      final permissionService = getIt<PermissionService>();
      if (!permissionService.isExternalStoragePermissionGranted) {
        final hasPermission = await permissionService
            .checkExternalStoragePermission();
        if (!hasPermission) {
          log('Permission denied');
          return null;
        }
      }

      final path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS,
      );
      final file = File('$path$configFilePath${resolveFileName()}');

      final fileString = file.readAsStringSync();

      // Uncomment for Collection Point emulated file
      // const fileString = '''
      //         {
      //             "DeviceId": 9,
      //             "ContractorCode": "TSTRETAIL",
      //             "CollectionPointCode": "1260"
      //         }''';

      // Uncomment for Counting Center emulated file
      // const fileString = '''
      //         {
      //             "DeviceId": 9,
      //             "ContractorCode": "TESTCO"
      //         }''';

      final result = jsonDecode(fileString) as Map<String, dynamic>;

      final resultNormalised = {
        for (final key in result.keys) key.toLowerCase(): result[key],
      };

      try {
        final config = LocalDeviceConfig.fromJson(resultNormalised);
        return config;
      } catch (exception, stackTrace) {
        LoggerService().trackError(exception, stackTrace: stackTrace);
        throw Exception('Failed to parse device config');
      }
    } catch (exception, stackTrace) {
      LoggerService().trackError(exception, stackTrace: stackTrace);
      log(exception.toString(), stackTrace: stackTrace);
      return null;
    }
  }

  Future<MobileDeviceConfig?> getMobileDeviceConfigByImei(String imei) async {
    try {
      final commonApi = getIt<CommonAPI>();
      final mobileDeviceConfig = await commonApi.getDeviceConfigurationByImei(
        imei,
      );
      return mobileDeviceConfig;
    } catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<Either<Failure, DeviceConfig>> getDeviceConfig(
    String configFilePath,
  ) async {
    try {
      // IMEI
      // 351060890082588 - PZ Segregacja bez szkła
      // 351060890086886 - PZ Bez segregacji bez szkła
      // 351060890087132 - Szkło bon wyświetlany

      final imeiResult = switch (getIt<AppConfigProvider>().configType) {
        ConfigType.lidl => await OkMobileBluefletch().getDeviceId(),
        _ => await OkMobileImei().getDeviceImei(),
      };

      MobileDeviceConfig? config;

      config = await getMobileDeviceConfigByImei(imeiResult ?? '');

      if (config != null) {
        await cacheMobileDeviceConfig(config);
        return Right(config);
      }

      config = await readMobileDeviceConfigFromCache();
      if (config != null) {
        return Right(config);
      }

      final sotiConfig = await getSotiDeviceConfig(configFilePath);
      if (sotiConfig != null) {
        return Right(sotiConfig);
      }

      throw Exception('No device config found');
    } catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);

      return const Left(
        Failure(
          message: 'Failed to load device config',
          type: FailureType.general,
          severity: FailureSeverity.error,
        ),
      );
    }
  }
}
