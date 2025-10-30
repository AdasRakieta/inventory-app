part of '../../ok_mobile_domain.dart';

@Environment(AppEnvironment.dev)
@Injectable(as: IDioConfig, order: -1)
class DevDioConfig implements IDioConfig {
  @override
  String get baseUrl => switch (getIt<AppConfigProvider>().configType) {
    ConfigType.lidl => 'https://dev.api-int.schwarz/sit/operator-kaucyjny',
    ConfigType.kaufland => 'https://api.dev.operatorkaucyjny.pl/mobile',
  };

  @override
  CertificateConfig get certificateConfig => DevCertificateConfig();

  @override
  List<Interceptor> get interceptors => [
    AuthInterceptor(authUseCases: getIt<AuthUsecases>()),
    LoggingInterceptor(),
  ];
}
