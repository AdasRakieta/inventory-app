part of '../../ok_mobile_common.dart';

class AppInsightsCustomPropertyKeys {
  static const String platform = 'platform';
  static const String environmentName = 'environmentName';
  static const String contractorId = 'contractorId';

  static const String deviceId = 'deviceId';
  static const String collectionPointCode = 'collectionPointCode';
  static const String contractorCode = 'contractorCode';
}

class SupportAdditionalMessages {
  static const String fileDeviceConfigError =
      'An error occurred while parsing the configuration file.'
      ' Please check its correctness.';
  static const String imeiDeviceConfigError =
      'An error occurred while retrieving the device configuration by IMEI.'
      ' Make sure the device is connected to the internet,'
      ' the device is registered in the system,'
      ' and the user has the appropriate permissions.';
  static const String fileDeviceConfigNotFoundError =
      'The configuration file was not found.'
      " Make sure the file is located in the device's documents directory.";
}

class LoggerService {
  factory LoggerService() => _instance;

  LoggerService._internal();

  static const String localLogsDirectory = '/Logs/';

  /// Has to be called before using any methods from [LoggerService].
  /// loggingLevel is the index of the [Severity] enum
  /// 0 - Verbose
  /// 1 - Information
  /// 2 - Warning
  /// 3 - Error
  /// 4 - Critical
  /// Any trace with a severity below loggingLevel will not be logged
  Future<void> create(int loggingLevel) async {
    _loggerConfig = getIt<ILoggerConfig>();
    _currentEnvironment = getIt<AppConfigProvider>().environment;

    _setLoggingLevel(loggingLevel);

    if (_currentEnvironment == AppEnvironmentEnum.offline) {
      return;
    }

    // TODO Severity level from config
    // final severity = RemoteConfigService().getSeverityLevel();

    final telemetryContext = TelemetryContext();

    final packageInfo = await PackageInfo.fromPlatform();

    telemetryContext.applicationVersion = packageInfo.version;
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      telemetryContext.device.model =
          '${androidInfo.manufacturer} ${androidInfo.model}';
      telemetryContext.device.osVersion = androidInfo.version.release;
    }

    telemetryClient = TelemetryClient(
      processor: BufferedProcessor(
        next: TransmissionProcessor(
          connectionString: _loggerConfig.connectionString,
          httpClient: getIt<AppHttpClient>().httpClient(),
          timeout: const Duration(seconds: 10),
        ),
        flushDelay: const Duration(seconds: 10),
      ),
      context: telemetryContext,
    );

    // Unbuffered telemetry client for error events
    errorClient = TelemetryClient(
      processor: TransmissionProcessor(
        connectionString: _loggerConfig.connectionString,
        httpClient: getIt<AppHttpClient>().httpClient(),
        timeout: const Duration(seconds: 10),
      ),
      context: telemetryContext,
    );
  }

  static final LoggerService _instance = LoggerService._internal();

  late TelemetryClient telemetryClient;
  late TelemetryClient errorClient;
  late TelemetryContext? telemetryContext;
  late ILoggerConfig _loggerConfig;
  late AppEnvironmentEnum _currentEnvironment;
  late Severity _loggingLevel;

  bool shouldLog(Severity severity) {
    return severity.index >= _loggingLevel.index &&
        _currentEnvironment != AppEnvironmentEnum.offline;
  }

  void _setLoggingLevel(int level) {
    if (level >= 0 && Severity.values.length - 1 >= level) {
      _loggingLevel = Severity.values[level];
    } else {
      _loggingLevel = Severity.verbose;
    }
  }

  void trackTrace(
    String eventName, {
    required String message,
    required Severity severity,
    bool bypassLoggingLevel = false,
    bool shouldFlush = false,
    Map<String, Object>? properties,
  }) {
    if (shouldLog(severity) || bypassLoggingLevel) {
      final userContext = getIt<AuthUsecases>().userData;
      final deviceContext = unwrapDeviceContext(
        getIt<DeviceConfigUsecases>().deviceConfig,
      );
      if (userContext != null) {
        telemetryClient.context.user.authUserId = userContext.id;
      }
      telemetryClient.trackTrace(
        severity: severity,
        message: message,
        additionalProperties: {
          AppInsightsCustomPropertyKeys.platform: 'mobile_app',
          AppInsightsCustomPropertyKeys.environmentName:
              _currentEnvironment.value,
          ...?properties,
          ...deviceContext,
          AppInsightsCustomPropertyKeys.contractorId:
              userContext?.contractorData?.id ?? 'Unavailable',
        },
      );
      if (shouldFlush) {
        telemetryClient.flush();
      }
    }
  }

  void trackError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object>? properties,
    bool isFatal = false,
    Failure? failure,
  }) {
    // TODO: Replace this check with proper mocks
    // This will allow us to verify that logs are sent correctly
    if (!isTestExecution) {
      if (shouldLog(Severity.critical)) {
        final userContext = getIt<AuthUsecases>().userData;
        final deviceContext = unwrapDeviceContext(
          getIt<DeviceConfigUsecases>().deviceConfig,
        );
        if (userContext != null) {
          errorClient.context.user.authUserId = userContext.id;
        }
        errorClient.trackError(
          severity: isFatal ? Severity.critical : Severity.error,
          error: error,
          stackTrace: stackTrace,
          additionalProperties: {
            AppInsightsCustomPropertyKeys.platform: 'mobile_app',
            AppInsightsCustomPropertyKeys.environmentName:
                _currentEnvironment.value,
            ...deviceContext,
            AppInsightsCustomPropertyKeys.contractorId:
                userContext?.contractorData?.id ?? 'Unavailable',
          },
        );

        saveLogsToFile(
          error,
          userContext: userContext,
          deviceContext: deviceContext,
          stackTrace: stackTrace,
          failure: failure,
          additionalProperties: {
            AppInsightsCustomPropertyKeys.platform: 'mobile_app',
            AppInsightsCustomPropertyKeys.environmentName:
                _currentEnvironment.value,
            ...deviceContext,
            AppInsightsCustomPropertyKeys.contractorId:
                userContext?.contractorData?.id ?? 'Unavailable',
            ...?properties,
          },
        );
      }
    }
  }

  Map<String, Object> unwrapDeviceContext(DeviceConfig? deviceContext) {
    return {
      AppInsightsCustomPropertyKeys.contractorCode:
          deviceContext?.contractorCode ?? 'Unavailable',
      AppInsightsCustomPropertyKeys.deviceId:
          deviceContext?.deviceId ?? 'Unavailable',
      AppInsightsCustomPropertyKeys.collectionPointCode:
          deviceContext?.collectionPointCode ?? 'Unavailable',
    };
  }

  // This method saves error logs to a local file
  Future<void> saveLogsToFile(
    Object error, {
    ContractorUser? userContext,
    Map<String, Object>? deviceContext,
    StackTrace? stackTrace,
    Map<String, Object>? additionalProperties,
    Failure? failure,
  }) async {
    if (isTestExecution ||
        await getIt<PermissionService>().requestExternalStoragePermission()) {
      await removeObsoleteLogs();

      final path = await getDirectory();

      final logFileName =
          '${DatesHelper.formatDateTimeOneLineOnlyDate(DateTime.now())}'
          '_error_logs'
          '.txt';
      final file = File('$path$localLogsDirectory$logFileName');

      final additionalInformationString = StringBuffer();
      if (additionalProperties != null && additionalProperties.isNotEmpty) {
        additionalProperties.forEach((key, value) {
          additionalInformationString.writeln('$key: $value');
        });
      }

      // Prepare context info string
      final contextInfo = StringBuffer()
        ..writeln(
          'User ID: ${userContext != null ? userContext.id : 'No data'}\n',
        )
        ..writeln('Additional information: \n$additionalInformationString')
        ..writeln(
          'Error details: ${failure?.message ?? 'No data'},\n'
          'Code: ${failure?.type ?? 'No data'}',
        );

      final logContent =
          contextInfo.toString() + _contstructLocalLog(error, stackTrace);

      if (file.existsSync()) {
        final existingContent = await file.readAsString();
        await file.writeAsString(logContent + existingContent);
      } else {
        file.createSync(recursive: true);
        await file.writeAsString(logContent);
      }
    }
  }

  Future<void> removeObsoleteLogs() async {
    final path = await getDirectory();

    final logsDir = Directory('$path$localLogsDirectory');
    if (!logsDir.existsSync()) return;

    final now = DateTime.now();
    final files = logsDir.listSync();
    for (final file in files) {
      if (file is File) {
        final dateParts = file.uri.pathSegments.last
            .substring(0, 10)
            .split('.')
            .reversed
            .toList();
        if (dateParts.length == 3) {
          final fileDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          if (now.difference(fileDate).inDays > 7) {
            await file.delete();
          }
        }
      }
    }
  }

  static String _contstructLocalLog(Object error, StackTrace? stackTrace) {
    final buffer = StringBuffer()
      ..writeln('\nTimestamp: ${DateTime.now().toIso8601String()}')
      ..writeln('Error: $error\n');
    if (stackTrace != null) {
      buffer.writeln('StackTrace:\n$stackTrace\n');
    }
    buffer.writeln('-------------------------\n');
    return buffer.toString();
  }

  static Future<String> getDirectory() async {
    if (isTestExecution) {
      return Directory.current.path;
    } else {
      return ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS,
      );
    }
  }
}
