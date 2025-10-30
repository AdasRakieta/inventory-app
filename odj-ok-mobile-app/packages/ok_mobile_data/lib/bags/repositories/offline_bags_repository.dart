part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IBagsRepository)
class OfflineBagsRepository implements IBagsRepository {
  OfflineBagsRepository();

  @override
  Future<Either<Failure, List<Bag>>> fetchOpenBags({
    required String collectionPointId,
  }) async {
    return Right([
      Bag(
        label: '1',
        packages: const [],
        type: BagType.can,
        id: '1',
        state: BagState.open,
        openedTime: DateTime(2025, 2, 12, 12, 23),
      ),
      Bag(
        label: '2',
        packages: const [],
        type: BagType.plastic,
        id: '2',
        state: BagState.open,
        openedTime: DateTime(2025, 2, 11, 12, 23),
      ),
      Bag(
        label: '3',
        packages: [
          Package(
            eanCode: '1',
            bagId: '3',
            deposit: 0.1,
            description: 'Example 1',
            quantity: 4,
            type: BagType.can,
          ),
        ],
        type: BagType.can,
        id: '3',
        state: BagState.open,
        openedTime: DateTime(2025, 4, 12, 12, 23),
      ),
      Bag(
        label: '4',
        packages: [
          Package(
            eanCode: '2',
            bagId: '4',
            deposit: 0.1,
            description: 'Example 2',
            quantity: 4,
            type: BagType.plastic,
          ),
        ],
        type: BagType.plastic,
        id: '4',
        state: BagState.open,
        openedTime: DateTime(2025, 3, 12, 12, 23),
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<Bag>>> fetchClosedBags({
    required String collectionPointId,
  }) async {
    return Right([
      Bag(
        label: '5',
        seal: '5',
        packages: const [],
        type: BagType.can,
        id: '5',
        closedTime: DateTime(2025, 2, 12, 12, 23),
      ),
      Bag(
        label: '6',
        seal: '6',
        packages: const [],
        type: BagType.plastic,
        id: '6',
        closedTime: DateTime(2025, 2, 12, 11, 23),
      ),
      Bag(
        label: '7',
        seal: '7',
        packages: [
          Package(
            eanCode: '3',
            bagId: '7',
            deposit: 0.1,
            description: 'Example 3',
            quantity: 4,
            type: BagType.can,
          ),
        ],
        type: BagType.can,
        id: '7',
        closedTime: DateTime(2025, 1, 12, 12, 23),
      ),
      Bag(
        label: '8',
        seal: '8',
        packages: [
          Package(
            eanCode: '4',
            bagId: '8',
            deposit: 0.1,
            description: 'Example 4',
            quantity: 4,
            type: BagType.plastic,
          ),
        ],
        type: BagType.plastic,
        id: '8',
        closedTime: DateTime(2025, 3, 1, 12, 23),
      ),
    ]);
  }

  @override
  Future<Either<Failure, Bag>> addBag(BagMetadata bag) async {
    final newBag = Bag.fromMetadata(bag, 'new_bag_id');
    return Right(newBag);
  }

  @override
  Future<Either<Failure, Unit?>> addPackage(Package package) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> updateBagLabel(
    String bagId, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> updateBagSeal(
    String bagId, {
    required String newSeal,
    required ActionReason reason,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> closeAndSealBag(
    String bagId, {
    required String seal,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> updateBag(
    String bagId, {
    required String newLabel,
    required String newSeal,
    required ActionReason reason,
  }) async {
    return const Right(null);
  }
}
