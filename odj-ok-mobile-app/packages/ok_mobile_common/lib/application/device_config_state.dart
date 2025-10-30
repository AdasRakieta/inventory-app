part of '../ok_mobile_common.dart';

class DeviceConfigState extends Equatable implements BaseState {
  const DeviceConfigState({
    required this.deviceConfig,
    required this.remoteConfiguration,
    required this.state,
    required this.result,
    required this.contractorData,
    this.deviceConfigError,
    this.collectionPointData,
  });

  factory DeviceConfigState.initial() {
    return DeviceConfigState(
      deviceConfig: null,
      remoteConfiguration: RemoteConfiguration.defaultConfig(),
      state: GeneralState.loaded,
      result: null,
      contractorData: null,
    );
  }

  DeviceConfigState copyWith({
    DeviceConfig? deviceConfig,
    RemoteConfiguration? remoteConfiguration,
    GeneralState? state,
    Result? Function()? result,
    CollectionPointData? collectionPointData,
    Failure? deviceConfigError,
    ContractorData? contractorData,
  }) {
    return DeviceConfigState(
      deviceConfig: deviceConfig ?? this.deviceConfig,
      remoteConfiguration: remoteConfiguration ?? this.remoteConfiguration,
      state: state ?? this.state,
      result: result != null ? result() : this.result,
      collectionPointData: collectionPointData ?? this.collectionPointData,
      deviceConfigError: deviceConfigError ?? this.deviceConfigError,
      contractorData: contractorData ?? this.contractorData,
    );
  }

  final DeviceConfig? deviceConfig;
  final RemoteConfiguration remoteConfiguration;
  final Result? result;
  final GeneralState state;
  final CollectionPointData? collectionPointData;
  final Failure? deviceConfigError;
  final ContractorData? contractorData;

  @override
  GeneralState get generalState => state;

  @override
  List<Object?> get props => [
    deviceConfig,
    remoteConfiguration,
    state,
    result,
    collectionPointData,
    contractorData,
    deviceConfigError,
  ];

  @override
  Result? get resultObject => result;
}

class RemoteConfiguration extends Equatable {
  const RemoteConfiguration(
    this.mobileAppConfiguration, {
    required this.masterDataV2FeatureFlag,
  });

  RemoteConfiguration.defaultConfig()
    : mobileAppConfiguration = MobileAppConfiguration(),
      masterDataV2FeatureFlag = false;

  factory RemoteConfiguration.fromJson(Map<String, dynamic> json) {
    return RemoteConfiguration(
      MobileAppConfiguration.fromJson(
        jsonDecode(json['MobileAppConfiguration'] as String)
            as Map<String, dynamic>,
      ),
      masterDataV2FeatureFlag: parseFeatureFlag(
        json['MasterDataV2-Mobile'] as String,
      ),
    );
  }

  static bool parseFeatureFlag(String flag) {
    switch (flag) {
      case 'True':
        return true;
      default:
        return false;
    }
  }

  final bool masterDataV2FeatureFlag;
  final MobileAppConfiguration mobileAppConfiguration;

  @override
  List<Object?> get props => [mobileAppConfiguration, masterDataV2FeatureFlag];
}

class MobileAppConfiguration {
  MobileAppConfiguration({
    List<BarcodeConfig>? scannerCodeFormats,
    List<BarcodeFormat>? cameraCodeFormats,
    String? configurationFilePath,
  }) : _scannerCodeFormats = scannerCodeFormats,
       _cameraCodeFormats = cameraCodeFormats,
       _configurationFilePath = configurationFilePath;

  factory MobileAppConfiguration.fromJson(Map<String, dynamic>? json) {
    return MobileAppConfiguration(
      scannerCodeFormats: (json?['ScannerCodeFormats'] as List<dynamic>?)
          ?.map(
            (e) => BarcodeConfig(
              barcodeType: BarcodeTypes.values.firstWhere(
                (barcodeType) => e == barcodeType.name,
              ),
            ),
          )
          .toList(),
      cameraCodeFormats: (json?['CameraCodeFormats'] as List<dynamic>?)
          ?.map((value) => BarcodeFormat.fromRawValue(value as int))
          .toList(),
      configurationFilePath: json?['ConfigurationFilePath'] as String?,
    );
  }

  List<BarcodeConfig>? _scannerCodeFormats;
  List<BarcodeFormat>? _cameraCodeFormats;
  String? _configurationFilePath;

  List<BarcodeConfig> get scannerCodeFormats =>
      _scannerCodeFormats ?? _fallbackScannerCodeFormats;

  List<BarcodeFormat> get cameraCodeFormats =>
      _cameraCodeFormats ?? _fallbackCameraCodeFormats;

  String get configurationFilePath =>
      _configurationFilePath ?? _defaultConfigurationFilePath;

  final List<BarcodeConfig> _fallbackScannerCodeFormats = [
    BarcodeConfig(barcodeType: BarcodeTypes.ean8),
    BarcodeConfig(barcodeType: BarcodeTypes.ean13),
    BarcodeConfig(barcodeType: BarcodeTypes.ean128),
    BarcodeConfig(barcodeType: BarcodeTypes.gs1DataBarExpanded),
    BarcodeConfig(barcodeType: BarcodeTypes.i2of5),
    BarcodeConfig(barcodeType: BarcodeTypes.qrCode),
  ];
  final List<BarcodeFormat> _fallbackCameraCodeFormats = [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
  ];
  final String _defaultConfigurationFilePath = '/Config/';
}

extension BarcodeFromJson on BarcodeFormat {
  static BarcodeFormat fromJson(Map<String, dynamic> json) {
    return BarcodeFormat.values.firstWhere(
      (e) => e.name == json['name'],
      orElse: () => BarcodeFormat.ean13, // Default value
    );
  }
}
