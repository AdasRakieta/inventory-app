part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IReceivalsRepository)
class OfflineReceivalsRepository implements IReceivalsRepository {
  OfflineReceivalsRepository();

  @override
  Future<Either<Failure, Bag?>> validateBag(
    String sealNumber,
    String countingCenterId,
  ) async {
    return Right(
      Bag(
        label: '1234567890',
        type: BagType.plastic,
        packages: const [],
        closedTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, int?>> confirmReceival(
    String countingCenterId,
    List<Bag> bags,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, ReceivalsResponse?>> getPlannedReceivals(
    String countingCenterId,
  ) async {
    return Right(
      ReceivalsResponse(
        ccPickups: [
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
            dateAdded: DateTime(2025, 4, 4, 12, 33),
            dateModified: DateTime(2025, 4, 4, 17, 02),
            status: PickupStatus.released,
            code: 'OD 050525 003',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 1',
              name: 'Collection Point 1',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24933',
            dateAdded: DateTime(2025, 4, 4, 12, 33),
            dateModified: DateTime(2025, 4, 4, 17, 02),
            status: PickupStatus.released,
            code: 'OD 050525 002',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 2',
              name: 'Collection Point 2',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24932',
            dateAdded: DateTime(2025, 5, 4, 12, 33),
            dateModified: DateTime(2025, 5, 12, 17, 02),
            status: PickupStatus.released,
            code: 'OD 050525 001',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 1',
              name: 'Collection Point 1',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
        ],
        packages: const [
          CCPackageAggregateData(packageMaterial: BagType.can, quantity: 15),
          CCPackageAggregateData(
            packageMaterial: BagType.plastic,
            quantity: 100,
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<Failure, ReceivalsResponse?>> getCollectedReceivals(
    String countingCenterId,
  ) async {
    return Right(
      ReceivalsResponse(
        ccPickups: [
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
            dateAdded: DateTime(2025, 4, 2, 12, 33),
            dateModified: DateTime(2025, 4, 4, 17, 02),
            status: PickupStatus.partiallyReceived,
            code: 'OD 050525 001',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 1',
              name: 'Collection Point 1',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
            dateAdded: DateTime(2025, 4, 2, 12, 33),
            dateModified: DateTime(2025, 4, 4, 17, 02),
            status: PickupStatus.received,
            code: 'OD 050525 003',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 4',
              name: 'Collection Point 4',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24933',
            dateAdded: DateTime(2025, 7, 4, 12, 33),
            dateModified: DateTime(2025, 4, 4, 17, 02),
            status: PickupStatus.received,
            code: 'OD 050525 002',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 3',
              name: 'Collection Point 3',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24932',
            dateAdded: DateTime(2025, 5, 7, 12, 33),
            dateModified: DateTime(2025, 5, 12, 17, 02),
            status: PickupStatus.received,
            code: 'OD 050525 004',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 2',
              name: 'Collection Point 2',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24933',
            dateAdded: DateTime(2025, 7, 5, 12, 33),
            dateModified: DateTime(2025, 6, 4, 17, 02),
            status: PickupStatus.received,
            code: 'OD 050525 005',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 3',
              name: 'Collection Point 3',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24932',
            dateAdded: DateTime(2025, 5, 7, 12, 33),
            dateModified: DateTime(2025, 5, 12, 17, 02),
            status: PickupStatus.received,
            code: 'OD 050525 006',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 2',
              name: 'Collection Point 2',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24933',
            dateAdded: DateTime(2025, 7, 4, 12, 33),
            dateModified: DateTime(2025, 4, 4, 17, 02),
            status: PickupStatus.received,
            code: 'OD 050525 007',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 3',
              name: 'Collection Point 3',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
          CCPickupData(
            id: '30b005ac-ab29-f011-8b3d-000d3ac24932',
            dateAdded: DateTime(2025, 5, 7, 12, 33),
            dateModified: DateTime(2025, 5, 12, 17, 02),
            status: PickupStatus.partiallyReceived,
            code: 'OD 050525 008',
            collectionPoint: const ContractorData(
              id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
              code: 'Collection Point 2',
              name: 'Collection Point 2',
              addressCity: 'City 1',
              krs: '123456789',
              court: 'District Court in City 1',
            ),
          ),
        ],
        packages: const [
          CCPackageAggregateData(packageMaterial: BagType.can, quantity: 200),
          CCPackageAggregateData(
            packageMaterial: BagType.plastic,
            quantity: 300,
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<Failure, Pickup>> getReceivalData({
    required String pickupId,
  }) async {
    return Right(
      Pickup(
        id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
        dateAdded: DateTime(2025, 4, 4, 12, 33),
        dateModified: DateTime(2025, 4, 4, 17, 02),
        status: PickupStatus.released,
        code: 'OD 050525 003',
        collectionPoint: const ContractorData(
          id: '30b005ac-ab29-f011-8b3d-000d3ac24997',
          code: 'Collection Point 1',
          name: 'Collection Point 1',
        ),
        countingCenter: const ContractorData(
          id: '6fd03b98-5707-f011-aaa7-000d3a256502',
          name: 'TEST Counting Center',
          code: 'TESTCO',
        ),
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
        statusHistory: [
          StatusHistoryItem(
            dateModified: DateTime(2025, 5, 3, 11, 33),
            status: PickupStatus.released,
          ),
          StatusHistoryItem(
            dateModified: DateTime(2025, 5, 4, 18, 28),
            status: PickupStatus.partiallyReceived,
          ),
          StatusHistoryItem(
            dateModified: DateTime(2025, 5, 6, 01, 47),
            status: PickupStatus.received,
          ),
        ],
      ),
    );
  }
}
