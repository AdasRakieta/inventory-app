part of '../../ok_mobile_domain.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IDioConfig, order: -1)
class OfflineDioConfig implements IDioConfig {
  @override
  String get baseUrl => '';

  @override
  CertificateConfig get certificateConfig => OfflineCertificateConfig();

  @override
  List<Interceptor> get interceptors => [
    AuthInterceptor(authUseCases: getIt<AuthUsecases>()),
    LoggingInterceptor(),
  ];
}
