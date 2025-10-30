part of '../../ok_mobile_domain.dart';

@lazySingleton
class ReturnsUsecases {
  ReturnsUsecases(this._returnsRepository, this._deviceConfigUsecases);

  final IReturnsRepository _returnsRepository;
  final DeviceConfigUsecases _deviceConfigUsecases;
  List<Return> _returns = <Return>[];

  Future<Either<Failure, Return>> closeReturn(Return returnToClose) async {
    final deviceConfigUsecases = getIt<DeviceConfigUsecases>();
    final result = await _returnsRepository.closeReturn(
      returnToClose,
      _deviceConfigUsecases.collectionPointData.id,
      deviceConfigUsecases.deviceConfig?.deviceId.toString() ?? '0',
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (data) {
        final confirmedReturn = returnToClose.copyWith(
          id: data.metadata.id,
          code: data.metadata.code,
          voucher: data.voucher,
        );

        return Right(confirmedReturn);
      },
    );
  }

  Future<Either<Failure, List<Return>>> fetchReturns() async {
    final fromFullDate = DateTime.now().subtract(const Duration(days: 7));
    final fromDate = DateTime(
      fromFullDate.year,
      fromFullDate.month,
      fromFullDate.day,
    );

    final result = await _returnsRepository.fetchReturns(
      dateFrom: fromDate,
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );

    return result.fold(Left.new, (returns) {
      _returns = List<Return>.from(returns)
        ..sort((a, b) => b.closedTime!.compareTo(a.closedTime!));

      return Right(_returns);
    });
  }

  List<Return> getReturns() => _returns;

  List<Return> getReturnsClosed() {
    return _returns
        .where((element) => element.state != ReturnState.ongoing)
        .toList();
  }

  Future<Either<Failure, Unit?>> requestVoucherPrint(
    String voucherId, {
    ActionReason? reprintReason,
  }) async {
    final result = await _returnsRepository.createVoucherAuditEntry(
      voucherId,
      VoucherAuditRequest(
        event: reprintReason == null
            ? AuditEvent.printRequested
            : AuditEvent.reprintRequested,
        reason: reprintReason,
      ),
    );

    return result.fold(Left.new, (_) => const Right(null));
  }

  Future<Either<Failure, Unit?>> confirmVoucherPrinted(String voucherId) async {
    final result = await _returnsRepository.createVoucherAuditEntry(
      voucherId,
      VoucherAuditRequest(event: AuditEvent.printSuccess),
    );

    return result.fold(Left.new, (_) => const Right(null));
  }

  Future<Either<Failure, String>> cancelVoucherPrint(
    String voucherId, {
    required ActionReason reason,
  }) async {
    final result = await _returnsRepository.createVoucherAuditEntry(
      voucherId,
      VoucherAuditRequest(event: AuditEvent.printAborted, reason: reason),
    );

    return result.fold(Left.new, Right.new);
  }

  Future<void> changeCachedData(Return openReturn) async {
    return _returnsRepository.changeCachedData(openReturn);
  }

  Future<Return?> getCachedData() async {
    return _returnsRepository.getCachedData();
  }

  Future<void> removeCache() async {
    return _returnsRepository.removeCachedData();
  }
}
