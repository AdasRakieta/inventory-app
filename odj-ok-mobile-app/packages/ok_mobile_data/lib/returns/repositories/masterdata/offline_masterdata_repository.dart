part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@LazySingleton(as: IMasterDataRepository)
class OfflineMasterdataRepository extends IMasterDataRepository {
  OfflineMasterdataRepository();

  @override
  Future<Either<Failure, List<Package>>> fetchPackages(
    DateTime? lastModifiedDate, {
    bool useMasterdataV2 = false,
  }) async {
    return Right([
      Package(
        eanCode: '1',
        deposit: 0.1,
        description: 'Example 1',
        type: BagType.can,
      ),
      Package(
        eanCode: '2',
        deposit: 0.1,
        description: 'Example 2',
        type: BagType.plastic,
      ),
      Package(
        eanCode: '3',
        deposit: 0.1,
        description: 'Example 3',
        type: BagType.can,
      ),
      Package(
        eanCode: '4',
        deposit: 0.1,
        description: 'Example 4',
        type: BagType.plastic,
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<Package>>> getPackagesFromDatabase({
    bool useMasterdataV2 = false,
  }) async {
    return Right([
      Package(
        eanCode: '1',
        deposit: 0.1,
        description: 'Example 1',
        type: BagType.can,
      ),
      Package(
        eanCode: '2',
        deposit: 0.1,
        description: 'Example 2',
        type: BagType.plastic,
      ),
      Package(
        eanCode: '3',
        deposit: 0.1,
        description: 'Example 3',
        type: BagType.can,
      ),
      Package(
        eanCode: '4',
        deposit: 0.1,
        description: 'Example 4',
        type: BagType.plastic,
      ),
    ]);
  }
}
