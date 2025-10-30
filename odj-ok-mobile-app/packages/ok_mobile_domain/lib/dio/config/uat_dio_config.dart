part of '../../ok_mobile_domain.dart';

@Environment(AppEnvironment.uat)
@Injectable(as: IDioConfig, order: -1)
class UatDioConfig implements IDioConfig {
  @override
  String get baseUrl => switch (getIt<AppConfigProvider>().configType) {
    ConfigType.lidl => 'https://qas.api-int.schwarz/sit/operator-kaucyjny',
    ConfigType.kaufland => 'https://api.uat.operatorkaucyjny.pl/mobile',
  };

  @override
  CertificateConfig get certificateConfig => UatCertificateConfig();

  @override
  List<Interceptor> get interceptors => [
    AuthInterceptor(authUseCases: getIt<AuthUsecases>()),
    LoggingInterceptor(),
  ];
}
