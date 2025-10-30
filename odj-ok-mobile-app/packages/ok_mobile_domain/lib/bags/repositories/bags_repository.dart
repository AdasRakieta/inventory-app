part of '../../ok_mobile_domain.dart';

abstract class IBagsRepository {
  Future<Either<Failure, List<Bag>>> fetchOpenBags({
    required String collectionPointId,
  });
  Future<Either<Failure, List<Bag>>> fetchClosedBags({
    required String collectionPointId,
  });
  Future<Either<Failure, Bag>> addBag(BagMetadata bag);
  Future<Either<Failure, Unit?>> closeAndSealBag(
    String bagId, {
    required String seal,
  });

  Future<Either<Failure, Unit?>> updateBag(
    String bagId, {
    required String newLabel,
    required String newSeal,
    required ActionReason reason,
  });

  Future<Either<Failure, Unit?>> updateBagLabel(
    String bagId, {
    required String newLabel,
    required ActionReason reason,
  });

  Future<Either<Failure, Unit?>> updateBagSeal(
    String bagId, {
    required String newSeal,
    required ActionReason reason,
  });
  Future<Either<Failure, Unit?>> addPackage(Package package);
}
