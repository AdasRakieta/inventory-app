part of '../../../ok_mobile_common.dart';

@Injectable(as: ILoggerConfig)
@Environment(AppEnvironment.uat)
class UatLoggerConfig implements ILoggerConfig {
  @override
  String get connectionString =>
      'InstrumentationKey=4cc3e125-24fc-4ad4-ad75-0caf6d691557;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=c1799968-fc0d-485a-bac0-588280059107'; // #gitleaks:allow
  @override
  String get environmentName => AppEnvironment.uat;
}
