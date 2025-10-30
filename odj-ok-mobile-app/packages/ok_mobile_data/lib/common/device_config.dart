part of '../ok_mobile_data.dart';

abstract class DeviceConfig {
  int get deviceId;
  String get contractorCode;
  String? get collectionPointCode;
  bool get isValid;
  bool get isInvalid;
  bool get isCollectionPoint;
}

class LocalDeviceConfig implements DeviceConfig {
  LocalDeviceConfig({
    required int deviceId,
    required String contractorCode,
    String? collectionPointCode,
  }) : _deviceId = deviceId,
       _contractorCode = contractorCode,
       _collectionPointCode = collectionPointCode;

  factory LocalDeviceConfig.fromJson(Map<String, dynamic> json) {
    return LocalDeviceConfig(
      deviceId: json['DeviceId'.toLowerCase()] as int,
      contractorCode: json['ContractorCode'.toLowerCase()] as String,
      collectionPointCode: json['CollectionPointCode'.toLowerCase()] as String?,
    );
  }

  factory LocalDeviceConfig.fromBlueFletchLauncherJson(
    Map<String, dynamic> json,
  ) {
    return LocalDeviceConfig(
      deviceId: switch (json['deviceId']) {
        final int value => value,
        final String value => int.tryParse(value) ?? -1,
        _ => -1,
      },
      contractorCode: json['contractorCode']?.toString() ?? '-1',
      collectionPointCode: json['collectionPointCode'] as String?,
    );
  }

  factory LocalDeviceConfig.empty() {
    return LocalDeviceConfig(deviceId: -1, contractorCode: '');
  }

  final int _deviceId;
  final String _contractorCode;
  final String? _collectionPointCode;

  @override
  int get deviceId => _deviceId;
  @override
  String get contractorCode => _contractorCode;
  @override
  String? get collectionPointCode => _collectionPointCode;

  @override
  bool get isCollectionPoint => collectionPointCode != null;

  @override
  bool get isValid => !(deviceId == -1 && contractorCode.isEmpty);
  @override
  bool get isInvalid => deviceId == -1 && contractorCode.isEmpty;
}

class MobileDeviceConfig implements DeviceConfig {
  MobileDeviceConfig({
    required this.id,
    required this.imei,
    required int deviceId,
    required this.mode,
    required this.status,
    required this.dateModified,
    required this.dateAdded,
    required this.collectionPointContractorCode,
    required this.countingCenterCode,
    required String? collectionPointCode,
  }) : _deviceId = deviceId,
       _collectionPointCode = collectionPointCode;

  factory MobileDeviceConfig.fromJson(Map<String, dynamic> json) {
    return MobileDeviceConfig(
      id: json['id'] as String,
      imei: json['imei'] as String,
      deviceId: json['deviceId'] as int,
      mode: Mode.values.firstWhere(
        (m) => m.jsonValue == (json['mode'] as String? ?? ''),
        orElse: () => Mode.invalid,
      ),
      status: json['status'] as String,
      dateModified: DateTime.parse(json['dateModified'] as String),
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      collectionPointContractorCode:
          json['collectionPointContractorCode'] as String?,
      countingCenterCode: json['countingCenterCode'] as String?,
      collectionPointCode: json['collectionPointCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imei': imei,
      'deviceId': _deviceId,
      'mode': mode.jsonValue,
      'status': status,
      'dateModified': dateModified.toIso8601String(),
      'dateAdded': dateAdded.toIso8601String(),
      'collectionPointContractorCode': collectionPointContractorCode,
      'countingCenterCode': countingCenterCode,
      'collectionPointCode': _collectionPointCode,
    };
  }

  final String id;
  final String imei;
  final int _deviceId;
  final Mode mode;
  final String status;
  final DateTime dateModified;
  final DateTime dateAdded;
  final String? collectionPointContractorCode;
  final String? countingCenterCode;
  final String? _collectionPointCode;

  @override
  String? get collectionPointCode => _collectionPointCode;

  @override
  String get contractorCode => switch (mode) {
    Mode.collectionPoint => collectionPointContractorCode ?? '',
    Mode.countingCenter => countingCenterCode ?? '',
    Mode.invalid => '',
  };

  @override
  int get deviceId => _deviceId;

  @override
  bool get isValid => !(deviceId == -1 && contractorCode.isEmpty);

  @override
  bool get isInvalid => deviceId == -1 && contractorCode.isEmpty;

  @override
  bool get isCollectionPoint => mode == Mode.collectionPoint;
}

enum Mode {
  collectionPoint,
  countingCenter,
  invalid;

  String get jsonValue {
    switch (this) {
      case Mode.collectionPoint:
        return 'CollectionPoint';
      case Mode.countingCenter:
        return 'CountingCenter';
      case Mode.invalid:
        return 'Invalid';
    }
  }
}
