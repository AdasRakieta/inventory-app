part of '../../ok_mobile_common.dart';

abstract class ILoggerConfig {
  ILoggerConfig({
    required this.connectionString,
    required this.environmentName,
  });
  final String connectionString;
  final String environmentName;
}
