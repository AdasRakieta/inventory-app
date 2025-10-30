part of '../../ok_mobile_domain.dart';

@singleton
class DeviceConfigUsecases {
  DeviceConfigUsecases(this._deviceConfigDatasource);

  final DeviceConfigDatasource _deviceConfigDatasource;

  DeviceConfig? deviceConfig;

  late CollectionPointData _collectionPointData;
  late ContractorData _collectionPointContractorData;

  CollectionPointData get collectionPointData => _collectionPointData;
  ContractorData get collectionPointContractorData =>
      _collectionPointContractorData;

  Future<Either<Failure, DeviceConfig>> populateDeviceConfig(
    String configFilePath,
  ) async {
    final result = await _deviceConfigDatasource.getDeviceConfig(
      configFilePath,
    );
    return result.fold(Left.new, (config) {
      deviceConfig = config;
      return Right(config);
    });
  }

  Future<Either<Failure, RemoteConfiguration>>
  populateRemoteConfiguration() async {
    final commonRepository = getIt<ICommonRepository>();
    final result = await commonRepository.getRemoteConfiguration();

    return result.fold(Left.new, (remoteConfig) {
      return Right(remoteConfig);
    });
  }

  Future<Either<Failure, ContractorData>> getCountingCenterData(
    String countingCenterCode,
  ) async {
    final commonRepository = getIt<ICommonRepository>();
    final result = await commonRepository.getCountingCenterData(
      countingCenterCode,
    );

    return result.fold(Left.new, (countingCenterData) {
      if (countingCenterData != null) {
        return Right(countingCenterData);
      } else {
        return const Left(
          Failure(
            message: 'Counting center not found',
            type: FailureType.general,
            severity: FailureSeverity.error,
          ),
        );
      }
    });
  }

  Future<Either<Failure, CollectionPointData>> getCollectionPointData(
    String collectionPointCode,
  ) async {
    final commonRepository = getIt<ICommonRepository>();
    final result = await commonRepository.getCollectionPoint(
      _collectionPointContractorData.id,
      deviceConfig!.collectionPointCode!,
    );

    return result.fold(Left.new, (collectionPointData) {
      _collectionPointData = collectionPointData;
      return Right(collectionPointData);
    });
  }

  Future<Either<Failure, ContractorData>> getCollectionPointContractorData(
    String collectionContractorPointCode,
  ) async {
    final commonRepository = getIt<ICommonRepository>();
    final result = await commonRepository.getCollectionPointContractor(
      collectionContractorPointCode,
    );
    return result.fold(Left.new, (collectionPointContractorData) async {
      final logoFetched = await _fetchContractorLogoIfNeeded(
        contractorId: collectionPointContractorData.id,
        isDigitalVoucherFlow:
            collectionPointContractorData.voucherDisplayType ==
            VoucherDisplayType.digital,
      );
      return await logoFetched.fold(Left.new, (_) {
        _collectionPointContractorData = collectionPointContractorData;
        return Right(collectionPointContractorData);
      });
    });
  }

  Future<Either<Failure, Unit?>> _fetchContractorLogoIfNeeded({
    required String contractorId,
    required bool isDigitalVoucherFlow,
  }) async {
    if (isDigitalVoucherFlow) {
      return const Right(null);
    }
    final cachedLastModifiedDate = await getCachedLogoLastModifiedDate();

    final commonRepository = getIt<ICommonRepository>();
    final result = await commonRepository.downloadLogo(
      contractorId: contractorId,
      lastModifiedDate: cachedLastModifiedDate,
    );

    return result.fold(Left.new, (logoBytes) async {
      if (logoBytes != null) {
        final logoPath = await LogoLocalDatasource.saveLogo(logoBytes);

        if (logoPath != null) {
          await LogoLocalDatasource.saveLogoLastModifiedDate(
            lastModifiedDate: DatesHelper.formatToIfModifiedSince(
              DateTime.now(),
            ),
          );
        }
      }
      return const Right(null);
    });
  }

  Future<String?> getCachedLogoLastModifiedDate() async {
    return LogoLocalDatasource.getCachedLogoLastModifiedDate();
  }

  Future<void> clearLogoData() async {
    await LogoLocalDatasource.clearLogo();
  }
}
