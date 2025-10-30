part of '../../ok_mobile_domain.dart';

@lazySingleton
class PickupsUsecases {
  PickupsUsecases(this._pickupsRepository);

  final IPickupsRepository _pickupsRepository;

  Future<Either<Failure, String>> confirmPickup({
    required String collectionPointId,
    List<Bag>? selectedBags,
  }) async {
    return _pickupsRepository.confirmPickup(
      bags: selectedBags,
      collectionPointId: collectionPointId,
    );
  }

  Future<Either<Failure, List<Pickup>>> fetchPickups(
    String collectionPointId,
  ) async {
    return _pickupsRepository.fetchPickups(
      collectionPointId: collectionPointId,
    );
  }

  Future<Either<Failure, Pickup>> getPickupData({
    required String pickupId,
  }) async {
    return _pickupsRepository.getPickupData(pickupId: pickupId);
  }
}
