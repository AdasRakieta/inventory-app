part of '../../ok_mobile_domain.dart';

@Environment(AppEnvironment.prd)
@Injectable(as: IDioConfig, order: -1)
class PrdDioConfig implements IDioConfig {
  @override
  String get baseUrl => switch (getIt<AppConfigProvider>().configType) {
    ConfigType.lidl => 'https://live.api-int.schwarz/sit/operator-kaucyjny',
    ConfigType.kaufland => 'https://api.panel.operatorkaucyjny.pl/mobile',
  };

  @override
  CertificateConfig get certificateConfig => PrdCertificateConfig();

  @override
  List<Interceptor> get interceptors => [
    AuthInterceptor(authUseCases: getIt<AuthUsecases>()),
    LoggingInterceptor(),
  ];
}
