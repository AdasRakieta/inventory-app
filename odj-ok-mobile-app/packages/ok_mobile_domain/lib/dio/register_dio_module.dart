part of '../ok_mobile_domain.dart';

@module
abstract class RegisterDioModule {
  @factoryMethod
  Dio dio(IDioConfig config) {
    final options = BaseOptions(baseUrl: config.baseUrl);
    final dio = Dio(options);
    dio.interceptors.addAll(config.interceptors);
    if (config.certificateConfig.isPinningEnabled) {
      dio.interceptors.add(
        CertificatePinningInterceptor(
          allowedSHAFingerprints:
              config.certificateConfig.allowedSHA256Fingerprints,
        ),
      );
    }
    return dio;
  }
}
