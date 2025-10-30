part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: ICommonRepository)
class OfflineCommonRepository implements ICommonRepository {
  OfflineCommonRepository();

  @override
  Future<Either<Failure, ContractorUser?>> getCurrentUser() async {
    return const Right(
      ContractorUser(
        id: '12345678',
        roles: [ContractorUserRole.storeUser],
        name: 'Test User',
        surname: 'Offline',
        email: 'store.user@test.pl',
        personalNumber: '1234567890',
      ),
    );
  }

  @override
  Future<Either<Failure, RemoteConfiguration>> getRemoteConfiguration() async {
    return Right(
      RemoteConfiguration(
        MobileAppConfiguration(),
        masterDataV2FeatureFlag: false,
      ),
    );
  }

  @override
  Future<Either<Failure, ContractorData?>> getCountingCenterData(
    String countingCenterCode,
  ) async {
    return const Right(
      ContractorData(
        id: '1234567890',
        name: 'Test',
        code: '1234567890',
        addressCity: 'Test City',
      ),
    );
  }

  @override
  Future<Either<Failure, CollectionPointData>> getCollectionPoint(
    String collectionPointId,
    String collectionPointCode,
  ) async {
    return const Right(
      CollectionPointData(
        id: '1',
        segregatesItems: true,
        code: 'OFFLINE',
        collectedPackagingType: CollectedPackagingTypeEnum.allTypes,
      ),
    );
  }

  @override
  Future<Either<Failure, ContractorData>> getCollectionPointContractor(
    String collectionPointId,
  ) async {
    return const Right(
      ContractorData(
        id: '1',
        name: 'Offline Collection Point Contractor',
        code: 'OFFLINE',
        addressCity: '123 Offline St',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> acceptTermsAndConditions() async =>
      const Right(null);

  @override
  Future<Either<Failure, Uint8List?>> downloadLogo({
    required String contractorId,
    String? lastModifiedDate,
  }) async {
    return const Right(null);
  }
}
