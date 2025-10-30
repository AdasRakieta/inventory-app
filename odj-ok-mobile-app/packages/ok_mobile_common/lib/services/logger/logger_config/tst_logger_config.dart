part of '../../../ok_mobile_common.dart';

@Injectable(as: ILoggerConfig)
@Environment(AppEnvironment.tst)
class TstLoggerConfig implements ILoggerConfig {
  @override
  String get connectionString =>
      'InstrumentationKey=8ae78c0a-2762-40c3-8733-39e7d525a516;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=4e78f204-144f-431b-ae62-b05c71bfaf5b'; // #gitleaks:allow
  @override
  String get environmentName => AppEnvironment.tst;
}
