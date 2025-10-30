part of '../../ok_mobile_domain.dart';

abstract class IReturnsRepository {
  Future<Either<Failure, List<Return>>> fetchReturns({
    required DateTime dateFrom,
    required String collectionPointId,
  });
  Future<Either<Failure, ({ReturnMetadata metadata, Voucher voucher})>>
  closeReturn(Return returnToClose, String collectionPointId, String deviceId);

  Future<Either<Failure, String>> createVoucherAuditEntry(
    String voucherId,
    VoucherAuditRequest requestBody,
  );

  Future<void> changeCachedData(Return openReturn);

  Future<Return?> getCachedData();

  Future<void> removeCachedData();
}
