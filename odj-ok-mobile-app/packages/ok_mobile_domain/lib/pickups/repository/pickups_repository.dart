part of '../../ok_mobile_domain.dart';

abstract class IPickupsRepository {
  Future<Either<Failure, String>> confirmPickup({
    required String collectionPointId,
    List<Bag>? bags,
    List<Box>? boxes,
  });

  Future<Either<Failure, List<Pickup>>> fetchPickups({
    required String collectionPointId,
  });

  Future<Either<Failure, Pickup>> getPickupData({required String pickupId});
}
