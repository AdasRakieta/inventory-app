part of '../ok_mobile_domain.dart';

abstract class IDioConfig {
  String get baseUrl;

  List<Interceptor> get interceptors;

  CertificateConfig get certificateConfig;
}
