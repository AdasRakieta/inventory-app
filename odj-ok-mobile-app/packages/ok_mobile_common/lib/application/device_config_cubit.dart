part of '../ok_mobile_common.dart';

@injectable
class DeviceConfigCubit extends Cubit<DeviceConfigState>
    implements ISnackBarCubit {
  DeviceConfigCubit(this._deviceConfigUsecases)
    : super(DeviceConfigState.initial());
  final DeviceConfigUsecases _deviceConfigUsecases;

  bool get isDigitalVoucherFlow =>
      state.contractorData?.voucherDisplayType == VoucherDisplayType.digital &&
      state.collectionPointData?.collectedPackagingType ==
          CollectedPackagingTypeEnum.glassOnly;

  Future<void> getDeviceConfig({bool isSupportUser = false}) async {
    if (state.deviceConfig?.isValid ?? false) return;

    if (state.state != GeneralState.loading) {
      emit(state.copyWith(state: GeneralState.loading));
    }

    final remoteConfig = await _getRemoteConfiguration();
    if (remoteConfig == null) return;

    final deviceConfig = await _getDeviceConfig(
      remoteConfig.mobileAppConfiguration.configurationFilePath,
    );
    if (deviceConfig == null) return;

    ContractorData? contractorData;
    CollectionPointData? collectionPointData;

    if (!isSupportUser && deviceConfig.contractorCode.isNotEmpty) {
      contractorData = await _getContractorData(deviceConfig.contractorCode);
      if (contractorData == null) return;

      if (deviceConfig.collectionPointCode != null) {
        final hasContractor = await _isCollectionPointContractor(
          deviceConfig.contractorCode,
        );
        if (!hasContractor) return;

        collectionPointData = await _getCollectionPointData(
          deviceConfig.collectionPointCode!,
        );
        if (collectionPointData == null) return;
      }
    }

    emit(
      state.copyWith(
        remoteConfiguration: remoteConfig,
        deviceConfig: deviceConfig,
        contractorData: contractorData,
        collectionPointData: collectionPointData,
        state: GeneralState.loaded,
      ),
    );
  }

  Future<RemoteConfiguration?> _getRemoteConfiguration() async {
    final result = await _deviceConfigUsecases.populateRemoteConfiguration();
    return result.fold((failure) {
      emit(
        state.copyWith(deviceConfigError: failure, state: GeneralState.error),
      );
      return null;
    }, (data) => data);
  }

  Future<DeviceConfig?> _getDeviceConfig(String path) async {
    final result = await _deviceConfigUsecases.populateDeviceConfig(path);
    return result.fold((failure) {
      emit(
        state.copyWith(deviceConfigError: failure, state: GeneralState.error),
      );
      return null;
    }, (data) => data);
  }

  Future<ContractorData?> _getContractorData(String contractorCode) async {
    final result = await _deviceConfigUsecases.getCountingCenterData(
      contractorCode,
    );
    return result.fold((failure) {
      emit(
        state.copyWith(deviceConfigError: failure, state: GeneralState.error),
      );
      return null;
    }, (data) => data);
  }

  Future<bool> _isCollectionPointContractor(String contractorCode) async {
    final result = await _deviceConfigUsecases.getCollectionPointContractorData(
      contractorCode,
    );
    return result.fold((failure) {
      emit(
        state.copyWith(deviceConfigError: failure, state: GeneralState.error),
      );
      return false;
    }, (_) => true);
  }

  Future<CollectionPointData?> _getCollectionPointData(String code) async {
    final result = await _deviceConfigUsecases.getCollectionPointData(code);
    return result.fold((failure) {
      emit(
        state.copyWith(deviceConfigError: failure, state: GeneralState.error),
      );
      return null;
    }, (data) => data);
  }

  void clear() => emit(DeviceConfigState.initial());

  bool checkIfPackageTypeIsAllowed(BagType? packageType) {
    if (packageType == null) {
      emit(
        state.copyWith(
          result: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.invalid_package_type,
          ),
        ),
      );
      return false;
    }
    final collectedPackagingType =
        state.collectionPointData?.collectedPackagingType;
    final isAllowed = switch ((collectedPackagingType, packageType)) {
      (CollectedPackagingTypeEnum.glassOnly, BagType.glass) => true,
      (CollectedPackagingTypeEnum.plasticAndCan, BagType.plastic) => true,
      (CollectedPackagingTypeEnum.plasticAndCan, BagType.can) => true,
      (CollectedPackagingTypeEnum.allTypes, _) => true,
      (_, _) => false,
    };
    if (!isAllowed) {
      emit(
        state.copyWith(
          result: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.scanned_package_of_not_allowed_type,
          ),
        ),
      );
    }
    return isAllowed;
  }

  @override
  void clearResult() => emit(state.copyWith(result: () => null));
}
