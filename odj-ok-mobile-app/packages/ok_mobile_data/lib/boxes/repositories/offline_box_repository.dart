part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IBoxRepository)
class OfflineBoxRepository implements IBoxRepository {
  OfflineBoxRepository();

  @override
  Future<Either<Failure, Box>> openNewBox({
    required String boxCode,
    required String collectionPointId,
  }) async {
    return Right(
      Box(
        dateOpened: DateTime.now(),
        id: boxCode,
        label: boxCode,
        isOpen: true,
      ),
    );
  }

  @override
  Future<Either<Failure, List<Box>>> fetchOpenBoxes({
    required String collectionPointId,
  }) async {
    return Right([
      Box(dateOpened: DateTime.now(), id: '1', label: '1', isOpen: true),
      Box(
        dateOpened: DateTime.now(),
        id: '2',
        label: '2',
        bags: [
          Bag(
            label: '5',
            packages: const [],
            type: BagType.can,
            id: '5',
            closedTime: DateTime(2025, 2, 12, 12, 23),
          ),
          Bag(
            label: '6',
            packages: const [],
            type: BagType.plastic,
            id: '6',
            closedTime: DateTime(2025, 2, 12, 11, 23),
          ),
        ],
        isOpen: true,
      ),
      Box(dateOpened: DateTime.now(), id: '3', label: '3', isOpen: true),
    ]);
  }

  @override
  Future<Either<Failure, Unit?>> addBagsToBox({
    required String boxId,
    required List<String> bagCodes,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> removeBagFromBox({
    required String boxId,
    required String bagId,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> closeBoxes(List<String> boxIds) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Box>>> fetchClosedBoxes({
    required String collectionPointId,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Success?>> updateBoxLabel(
    String id, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    return const Right(Success());
  }
}
