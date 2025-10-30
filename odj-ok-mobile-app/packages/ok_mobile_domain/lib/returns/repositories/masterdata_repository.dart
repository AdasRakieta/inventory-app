part of '../../ok_mobile_domain.dart';

abstract class IMasterDataRepository {
  Future<Either<Failure, List<Package>>> fetchPackages(
    DateTime? lastModifiedDate,
  );
  Future<Either<Failure, List<Package>>> getPackagesFromDatabase();
}
