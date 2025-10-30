part of '../../../ok_mobile_data.dart';

@Injectable(
  as: IReceivalsRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class ReceivalsRepositoryImpl implements IReceivalsRepository {
  ReceivalsRepositoryImpl(this._countingCenterAPI);

  final CountingCenterAPI _countingCenterAPI;

  @override
  Future<Either<Failure, Bag?>> validateBag(
    String sealNumber,
    String countingCenterId,
  ) async {
    try {
      final bag = await _countingCenterAPI.validateBag(
        sealNumber,
        countingCenterId,
      );
      return Right(bag);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.bag_not_found,
          ),
          on409: () {
            final responseData = ExceptionHelper.decodeResponse(e.response!);
            return ExceptionHelper.resolveFailureType(
              responseData['detail'] as String,
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, int?>> confirmReceival(
    String countingCenterId,
    List<Bag> bags,
  ) async {
    try {
      final receivalData = Receival(
        bagIds: bags.map((e) => SimpleDto(id: e.id!)).toList(),
        countingCenterId: countingCenterId,
      );
      final result = await _countingCenterAPI.confirmReceival(receivalData);
      return Right(result.response.statusCode);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.cc_not_found,
          ),
        ),
      );
    } catch (e, stacktrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stacktrace),
      );
    }
  }

  @override
  Future<Either<Failure, ReceivalsResponse?>> getPlannedReceivals(
    String countingCenterId,
  ) async {
    try {
      final result = await _countingCenterAPI.getPlannedReceivals(
        countingCenterId,
      );
      return Right(ReceivalsResponse.fromResponseBody(result));
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.cc_not_found,
          ),
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, ReceivalsResponse?>> getCollectedReceivals(
    String countingCenterId,
  ) async {
    try {
      final result = await _countingCenterAPI.getCollectedReceivals(
        countingCenterId,
      );
      return Right(ReceivalsResponse.fromResponseBody(result));
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.cc_not_found,
          ),
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, Pickup>> getReceivalData({
    required String pickupId,
  }) async {
    try {
      final pickupData = await _countingCenterAPI.getReceivalData(pickupId);
      return Right(pickupData);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.pickup_not_found,
          ),
        ),
      );
    } catch (e, stacktrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stacktrace),
      );
    }
  }
}
