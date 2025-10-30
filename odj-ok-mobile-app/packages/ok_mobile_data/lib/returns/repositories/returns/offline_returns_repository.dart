part of '../../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IReturnsRepository)
class OfflineReturnsRepository implements IReturnsRepository {
  OfflineReturnsRepository();

  final ReturnsLocalDatasource _returnsLocalDatasource =
      ReturnsLocalDatasource();

  @override
  Future<Either<Failure, List<Return>>> fetchReturns({
    required DateTime dateFrom,
    required String collectionPointId,
  }) async {
    return Right([
      Return(
        id: '1',
        code: 'ZW 1',
        state: ReturnState.ongoing,
        packages: [
          Package(
            eanCode: '1',
            bagId: '3',
            deposit: 0.1,
            description: 'Example 1',
            quantity: 4,
            type: BagType.can,
          ),
          Package(
            eanCode: '2',
            bagId: '4',
            deposit: 0.1,
            description: 'Example 2',
            quantity: 4,
            type: BagType.plastic,
          ),
          Package(
            eanCode: '3',
            bagId: '7',
            deposit: 0.1,
            description: 'Example 3',
            quantity: 4,
            type: BagType.can,
          ),
          Package(
            eanCode: '4',
            bagId: '8',
            deposit: 0.1,
            description: 'Example 4',
            quantity: 4,
            type: BagType.plastic,
          ),
        ],
        closedTime: DateTime.now(),
        voucher: Voucher(id: '1', code: '1234', depositValue: 1),
      ),
      Return(
        id: '2',
        code: 'ZW 2',
        state: ReturnState.unfinished,
        packages: [
          Package(
            eanCode: '1',
            bagId: '3',
            deposit: 0.5,
            description: 'Example 1',
            quantity: 2,
            type: BagType.can,
          ),
          Package(
            eanCode: '2',
            bagId: '4',
            deposit: 1,
            description: 'Example 2',
            quantity: 8,
            type: BagType.plastic,
          ),
        ],
        closedTime: DateTime.now(),
        voucher: Voucher(id: '2', code: '1234', depositValue: 1),
      ),
      Return(
        id: '3',
        code: 'ZW 3',
        state: ReturnState.canceled,
        packages: [
          Package(
            eanCode: '3',
            bagId: '7',
            deposit: 0.1,
            description: 'Example 3',
            quantity: 10,
            type: BagType.can,
          ),
          Package(
            eanCode: '4',
            bagId: '8',
            deposit: 0.25,
            description: 'Example 4',
            quantity: 2,
            type: BagType.plastic,
          ),
        ],
        closedTime: DateTime.now(),
        voucherCancellationReason: ActionReason.clientResignation,
        voucher: Voucher(id: '2', code: '1234', depositValue: 1),
      ),
      Return(
        id: '4',
        code: 'ZW 4',
        state: ReturnState.printed,
        packages: [
          Package(
            eanCode: '1',
            bagId: '3',
            deposit: 0.1,
            description: 'Example 1',
            quantity: 4,
            type: BagType.can,
          ),
          Package(
            eanCode: '2',
            bagId: '4',
            deposit: 0.1,
            description: 'Example 2',
            quantity: 4,
            type: BagType.plastic,
          ),
          Package(
            eanCode: '3',
            bagId: '7',
            deposit: 0.1,
            description: 'Example 3',
            quantity: 4,
            type: BagType.can,
          ),
          Package(
            eanCode: '4',
            bagId: '8',
            deposit: 0.1,
            description: 'Example 4',
            quantity: 4,
            type: BagType.plastic,
          ),
        ],
        closedTime: DateTime.now(),
        voucher: Voucher(id: '4', code: '1234', depositValue: 1),
      ),
      Return(
        id: '5',
        code: 'ZW 5',
        state: ReturnState.printed,
        packages: [
          Package(
            eanCode: '1',
            bagId: '3',
            deposit: 0.1,
            description: 'Example 1',
            quantity: 4,
            type: BagType.can,
          ),
          Package(
            eanCode: '2',
            bagId: '4',
            deposit: 0.1,
            description: 'Example 2',
            quantity: 4,
            type: BagType.plastic,
          ),
          Package(
            eanCode: '3',
            bagId: '7',
            deposit: 0.1,
            description: 'Example 3',
            quantity: 4,
            type: BagType.can,
          ),
          Package(
            eanCode: '4',
            bagId: '8',
            deposit: 0.1,
            description: 'Example 4',
            quantity: 4,
            type: BagType.plastic,
          ),
        ],
        closedTime: DateTime.now().subtract(const Duration(days: 1)),
        voucher: Voucher(id: '4', code: '1234', depositValue: 1),
      ),
    ]);
  }

  @override
  Future<Either<Failure, ({ReturnMetadata metadata, Voucher voucher})>>
  closeReturn(
    Return returnToClose,
    String collectionPointId,
    String deviceId,
  ) async {
    return Right((
      metadata: ReturnMetadata(code: returnToClose.id, id: returnToClose.id),
      voucher: Voucher(
        id: '1',
        code: '1234',
        depositValue: returnToClose.packages.fold<double>(
          0,
          (previousValue, element) =>
              previousValue + element.deposit * element.quantity,
        ),
      ),
    ));
  }

  @override
  Future<Either<Failure, String>> createVoucherAuditEntry(
    String voucherId,
    VoucherAuditRequest requestBody,
  ) async {
    return Right(requestBody.reason?.name ?? '');
  }

  @override
  Future<void> changeCachedData(Return openReturn) async {
    await _returnsLocalDatasource.setData(json.encode(openReturn.toJson()));
  }

  @override
  Future<Return?> getCachedData() async {
    final data = await _returnsLocalDatasource.getData();

    return data != null
        ? Return.fromJson(json.decode(data) as Map<String, dynamic>)
        : null;
  }

  @override
  Future<void> removeCachedData() async {
    await _returnsLocalDatasource.removeData();
  }
}
