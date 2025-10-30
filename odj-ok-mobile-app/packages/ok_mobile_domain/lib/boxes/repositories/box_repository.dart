part of '../../ok_mobile_domain.dart';

abstract class IBoxRepository {
  Future<Either<Failure, Box>> openNewBox({
    required String boxCode,
    required String collectionPointId,
  });

  Future<Either<Failure, List<Box>>> fetchOpenBoxes({
    required String collectionPointId,
  });

  Future<Either<Failure, List<Box>>> fetchClosedBoxes({
    required String collectionPointId,
  });

  Future<Either<Failure, Unit?>> addBagsToBox({
    required String boxId,
    required List<String> bagCodes,
  });

  Future<Either<Failure, Unit?>> removeBagFromBox({
    required String boxId,
    required String bagId,
  });

  Future<Either<Failure, Unit?>> closeBoxes(List<String> boxIds);

  Future<Either<Failure, Success?>> updateBoxLabel(
    String id, {
    required String newLabel,
    required ActionReason reason,
  });
}
