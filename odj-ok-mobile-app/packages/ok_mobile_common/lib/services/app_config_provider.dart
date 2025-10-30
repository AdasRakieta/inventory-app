part of '../ok_mobile_common.dart';

@Singleton(order: -1)
class AppConfigProvider {
  factory AppConfigProvider() {
    const flavorString = String.fromEnvironment('FLAVOR');
    const configTypeString = String.fromEnvironment('CONFIG_TYPE');
    return AppConfigProvider._(
      environment: AppEnvironmentEnum.fromString(flavorString),
      configType: ConfigType.fromString(configTypeString),
    );
  }

  AppConfigProvider._({required this.environment, required this.configType});

  bool get isLidl => configType == ConfigType.lidl;

  bool get isDefault => configType == ConfigType.kaufland;

  final AppEnvironmentEnum environment;
  final ConfigType configType;
}

enum AppEnvironmentEnum {
  prd(AppEnvironment.prd),
  uat(AppEnvironment.uat),
  tst(AppEnvironment.tst),
  dev(AppEnvironment.dev),
  offline(AppEnvironment.offline);

  const AppEnvironmentEnum(this.value);

  final String value;

  static AppEnvironmentEnum fromString(String flavor) {
    return AppEnvironmentEnum.values.firstWhere(
      (f) => f.value == flavor,
      orElse: () => throw UnsupportedError('Unsupported Flavor: $flavor'),
    );
  }
}

class AppEnvironment {
  static const String prd = 'prd';
  static const String uat = 'uat';
  static const String tst = 'tst';
  static const String dev = 'dev';
  static const String offline = 'offline';
}

enum ConfigType {
  lidl('lidl'),
  kaufland('kaufland');

  const ConfigType(this.value);
  final String value;

  static ConfigType fromString(String value) {
    return ConfigType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw UnsupportedError('Unsupported ConfigType: $value'),
    );
  }
}
