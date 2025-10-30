part of '../../ok_mobile_domain.dart';

abstract class IReceivalsRepository {
  Future<Either<Failure, Bag?>> validateBag(
    String sealNumber,
    String countingCenterId,
  );

  Future<Either<Failure, int?>> confirmReceival(
    String countingCenterId,
    List<Bag> bags,
  );

  Future<Either<Failure, ReceivalsResponse?>> getPlannedReceivals(
    String countingCenterId,
  );

  Future<Either<Failure, ReceivalsResponse?>> getCollectedReceivals(
    String countingCenterId,
  );

  Future<Either<Failure, Pickup>> getReceivalData({required String pickupId});
}
