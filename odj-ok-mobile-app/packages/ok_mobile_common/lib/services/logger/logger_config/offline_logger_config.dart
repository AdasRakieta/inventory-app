part of '../../../ok_mobile_common.dart';

@Injectable(as: ILoggerConfig)
@Environment(AppEnvironment.offline)
class OfflineLoggerConfig implements ILoggerConfig {
  @override
  String get connectionString => '';
  @override
  String get environmentName => AppEnvironment.offline;
}
