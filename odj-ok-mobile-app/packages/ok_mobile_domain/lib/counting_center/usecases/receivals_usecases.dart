part of '../../ok_mobile_domain.dart';

@lazySingleton
class ReceivalsUsecases {
  ReceivalsUsecases(this._receivalsRepository);

  final IReceivalsRepository _receivalsRepository;

  Future<Either<Failure, Bag?>> validateBag(
    String sealNumber,
    String countingCenterId,
  ) async {
    return _receivalsRepository.validateBag(sealNumber, countingCenterId);
  }

  Future<Either<Failure, int?>> confirmReceival(
    List<Bag> bags,
    String countingCenterId,
  ) async {
    return _receivalsRepository.confirmReceival(countingCenterId, bags);
  }

  Future<Either<Failure, ReceivalsResponse?>> getPlannedReceivals(
    String countingCenterId,
  ) async {
    return _receivalsRepository.getPlannedReceivals(countingCenterId);
  }

  Future<Either<Failure, ReceivalsResponse?>> getCollectedReceivals(
    String countingCenterId,
  ) async {
    return _receivalsRepository.getCollectedReceivals(countingCenterId);
  }

  Future<Either<Failure, Pickup>> getReceivalData({
    required String pickupId,
  }) async {
    return _receivalsRepository.getReceivalData(pickupId: pickupId);
  }
}
