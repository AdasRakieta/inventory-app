part of '../../ok_mobile_domain.dart';

@lazySingleton
class BoxUsecases {
  BoxUsecases(this._boxRepository, this._deviceConfigUsecases);

  final IBoxRepository _boxRepository;
  final DeviceConfigUsecases _deviceConfigUsecases;

  Future<Either<Failure, Box>> openNewBox({required String boxCode}) async {
    final result = await _boxRepository.openNewBox(
      boxCode: boxCode,
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (box) {
        return Right(box);
      },
    );
  }

  Future<Either<Failure, List<Box>>> fetchOpenBoxes() async {
    final result = await _boxRepository.fetchOpenBoxes(
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (boxes) {
        return Right(
          boxes..sort((a, b) => -a.dateOpened.compareTo(b.dateOpened)),
        );
      },
    );
  }

  Future<Either<Failure, List<Box>>> fetchClosedBoxes() async {
    final result = await _boxRepository.fetchClosedBoxes(
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (boxes) {
        return Right(
          boxes..sort((a, b) => -a.dateOpened.compareTo(b.dateOpened)),
        );
      },
    );
  }

  Future<Either<Failure, Success?>> addBagsToBox({
    required String boxId,
    required List<String> bagCodes,
  }) async {
    final result = await _boxRepository.addBagsToBox(
      boxId: boxId,
      bagCodes: bagCodes,
    );

    return result.fold(
      Left.new,
      (_) => Right(
        Success(
          message: bagCodes.length == 1
              ? S.current.bag_was_added_to_box
              : S.current.all_bags_added_to_box,
        ),
      ),
    );
  }

  Future<Either<Failure, Success?>> removeBagFromBox({
    required String boxId,
    required String bagId,
  }) async {
    final result = await _boxRepository.removeBagFromBox(
      boxId: boxId,
      bagId: bagId,
    );

    return result.fold(
      Left.new,
      (_) => Right(Success(message: S.current.bag_was_removed_from_box)),
    );
  }

  Future<Either<Failure, Success?>> closeBoxes(List<String> boxIds) async {
    final result = await _boxRepository.closeBoxes(boxIds);

    return result.fold(
      Left.new,
      (_) => Right(
        Success(
          message: boxIds.length == 1
              ? S.current.box_was_closed
              : S.current.all_boxes_closed,
        ),
      ),
    );
  }

  Future<Either<Failure, Success?>> updateBoxLabel(
    String id, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    final result = await _boxRepository.updateBoxLabel(
      id,
      newLabel: newLabel,
      reason: reason,
    );

    return result.fold(
      Left.new,
      (_) => Right(Success(message: S.current.label_has_been_changed)),
    );
  }
}
