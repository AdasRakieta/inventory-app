part of '../../ok_mobile_domain.dart';

@Injectable(order: -1)
class ProxyConfig {
  late final ConfigType _configType = getIt<AppConfigProvider>().configType;

  bool get shouldUseProxy {
    return switch (_configType) {
      ConfigType.lidl => true,
      _ => false,
    };
  }

  String get proxyHost {
    return switch (_configType) {
      ConfigType.lidl => 'se1-mwg-p03.schwarz',
      _ => '',
    };
  }

  int get proxyPort {
    return switch (_configType) {
      ConfigType.lidl => 8056,
      _ => 0,
    };
  }

  String get address => '$proxyHost:$proxyPort';
}
