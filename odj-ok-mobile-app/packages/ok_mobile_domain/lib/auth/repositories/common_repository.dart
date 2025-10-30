part of '../../ok_mobile_domain.dart';

abstract class ICommonRepository {
  Future<Either<Failure, void>> acceptTermsAndConditions();

  Future<Either<Failure, ContractorUser?>> getCurrentUser();

  Future<Either<Failure, ContractorData?>> getCountingCenterData(
    String countingCenterCode,
  );

  Future<Either<Failure, CollectionPointData>> getCollectionPoint(
    String collectionPointId,
    String collectionPointCode,
  );

  Future<Either<Failure, ContractorData>> getCollectionPointContractor(
    String collectionPointId,
  );

  Future<Either<Failure, RemoteConfiguration>> getRemoteConfiguration();

  Future<Either<Failure, Uint8List?>> downloadLogo({
    required String contractorId,
    String? lastModifiedDate,
  });
}
