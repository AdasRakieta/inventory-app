part of '../../ok_mobile_domain.dart';

@Environment(AppEnvironment.tst)
@Injectable(as: IDioConfig, order: -1)
class TstDioConfig implements IDioConfig {
  @override
  String get baseUrl => switch (getIt<AppConfigProvider>().configType) {
    ConfigType.lidl => 'https://test.api-int.schwarz/sit/operator-kaucyjny',
    ConfigType.kaufland => 'https://api.tst.operatorkaucyjny.pl/mobile',
  };

  @override
  CertificateConfig get certificateConfig => TstCertificateConfig();

  @override
  List<Interceptor> get interceptors => [
    AuthInterceptor(authUseCases: getIt<AuthUsecases>()),
    LoggingInterceptor(),
  ];
}
