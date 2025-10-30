part of '../../../ok_mobile_common.dart';

@Injectable(as: ILoggerConfig)
@Environment(AppEnvironment.dev)
class DevLoggerConfig implements ILoggerConfig {
  @override
  String get connectionString =>
      'InstrumentationKey=e044974b-e7bd-44eb-90eb-19ce32515325;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=1553c0f0-49b4-414a-ac8f-2d24bd1e0d04'; // #gitleaks:allow
  @override
  String get environmentName => AppEnvironment.dev;
}
