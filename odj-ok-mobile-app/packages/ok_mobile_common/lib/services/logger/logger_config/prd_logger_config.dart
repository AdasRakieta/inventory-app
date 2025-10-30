part of '../../../ok_mobile_common.dart';

@Injectable(as: ILoggerConfig)
@Environment(AppEnvironment.prd)
class PrdLoggerConfig implements ILoggerConfig {
  @override
  String get connectionString =>
      'InstrumentationKey=66ef4293-5332-4072-8667-f30b74c9888f;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=c9badb72-0ae4-4575-ab35-60241f0e3bc9'; // #gitleaks:allow
  @override
  String get environmentName => AppEnvironment.prd;
}
