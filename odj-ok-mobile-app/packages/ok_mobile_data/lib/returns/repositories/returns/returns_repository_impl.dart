part of '../../../ok_mobile_data.dart';

@Injectable(
  as: IReturnsRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class ReturnsRepositoryImpl implements IReturnsRepository {
  ReturnsRepositoryImpl(this._returnsApi, this._vouchersApi);
  final ReturnsAPI _returnsApi;
  final VouchersApi _vouchersApi;
  final ReturnsLocalDatasource _returnsLocalDatasource =
      ReturnsLocalDatasource();

  @override
  Future<Either<Failure, List<Return>>> fetchReturns({
    required DateTime dateFrom,
    required String collectionPointId,
  }) async {
    try {
      final response = await _returnsApi.fetchReturns(
        dateFrom.toUtc().toIso8601String(),
        collectionPointId,
      );
      return Right(response.map(Return.fromEntity).toList());
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(e, stackTrace: stackTrace),
      );
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, ({ReturnMetadata metadata, Voucher voucher})>>
  closeReturn(
    Return returnToClose,
    String collectionPointId,
    String deviceId,
  ) async {
    final packages = returnToClose.packages.map(BagItem.fromDomain).toList();
    try {
      final response = await _returnsApi.closeReturn(
        ReturnDto(
          items: packages,
          collectionPointId: collectionPointId,
          deviceId: deviceId,
        ),
      );

      final voucherEntity = response.voucherEntity;
      final closedReturnEntity = response.closedReturn;

      return Right((metadata: closedReturnEntity, voucher: voucherEntity));
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(e, stackTrace: stackTrace),
      );
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, String>> createVoucherAuditEntry(
    String voucherId,
    VoucherAuditRequest requestBody,
  ) async {
    try {
      final result = await _vouchersApi.createVoucherAuditEntry(
        voucherId,
        requestBody,
      );

      return Right(result);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(e, stackTrace: stackTrace),
      );
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
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
