part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IPickupsRepository)
class OfflinePickupsRepository implements IPickupsRepository {
  @override
  Future<Either<Failure, String>> confirmPickup({
    required String collectionPointId,
    List<Bag>? bags,
    List<Box>? boxes,
  }) async {
    return const Right('');
  }

  @override
  Future<Either<Failure, List<Pickup>>> fetchPickups({
    required String collectionPointId,
  }) async {
    return Right([
      Pickup(
        status: PickupStatus.released,
        code: 'OZ 12345',
        id: '1',
        dateAdded: DateTime(2025, 5, 3),
      ),
      Pickup(
        status: PickupStatus.received,
        code: 'OZ 123534',
        id: '2',
        dateAdded: DateTime(2025, 2, 22),
      ),
      Pickup(
        status: PickupStatus.partiallyReceived,
        code: 'OZ 745674',
        id: '3',
        dateAdded: DateTime(2025, 4, 30),
      ),
      Pickup(
        status: PickupStatus.partiallyReceived,
        code: 'OZ 868756',
        id: '4',
        dateAdded: DateTime(2025, 2, 22),
      ),
      Pickup(
        status: PickupStatus.received,
        code: 'OZ 458478',
        id: '5',
        dateAdded: DateTime(2025, 2, 22),
      ),
    ]);
  }

  @override
  Future<Either<Failure, Pickup>> getPickupData({
    required String pickupId,
  }) async {
    if (pickupId == '1') {
      return Right(
        Pickup(
          status: PickupStatus.released,
          code: 'OZ 12345',
          dateAdded: DateTime(2025, 5, 3),
          statusHistory: const [],
          bags: const [],
          countingCenter: const ContractorData(
            id: '6fd03b98-5707-f011-aaa7-000d3a256502',
            name: 'TEST Counting Center',
            code: 'TESTCO',
          ),
          collectionPoint: const ContractorData(
            id: '18ff9a89-b7f8-4355-9587-6e9d97bf6a36',
            name: 'Punkt zbiórki 2_B',
            code: '1260',
          ),
        ),
      );
    }
    return Right(
      Pickup(
        status: PickupStatus.received,
        code: 'OZ 12345',
        id: pickupId,
        dateAdded: DateTime(2025, 5, 3),
        dateModified: DateTime(2025, 5, 6),
        statusHistory: [
          StatusHistoryItem(
            dateModified: DateTime(2025, 5, 3, 11, 33),
            status: PickupStatus.released,
          ),
          StatusHistoryItem(
            dateModified: DateTime(2025, 5, 4, 18, 28),
            status: PickupStatus.partiallyReceived,
          ),
        ],
        packages: [
          PickupPackageData(packageMaterial: BagType.plastic, quantity: 20),
          PickupPackageData(packageMaterial: BagType.can, quantity: 10),
        ],
        bags: [
          Bag(
            id: '5f021ff0-b316-f011-8b3d-000d3ac24c12',
            closedTime: DateTime(2025, 04, 11, 11, 47, 21),
            type: BagType.plastic,
            label: '5658882',
            seal: '22225555',
            packages: [
              Package(eanCode: '25921953', quantity: 3),
              Package(eanCode: '20012205', quantity: 3),
              Package(eanCode: '25921953', quantity: 1),
              Package(eanCode: '20012205', quantity: 10),
            ],
          ),
        ],
        countingCenter: const ContractorData(
          id: '6fd03b98-5707-f011-aaa7-000d3a256502',
          name: 'TEST Counting Center',
          code: 'TESTCO',
        ),
        collectionPoint: const ContractorData(
          id: '18ff9a89-b7f8-4355-9587-6e9d97bf6a36',
          name: 'Punkt zbiórki 2_B',
          code: '1260',
        ),
      ),
    );
  }
}
