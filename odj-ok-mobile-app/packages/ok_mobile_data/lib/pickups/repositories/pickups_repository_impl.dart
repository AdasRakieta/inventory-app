part of '../../../ok_mobile_data.dart';

@Injectable(
  as: IPickupsRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class PickupsRepositoryImpl implements IPickupsRepository {
  PickupsRepositoryImpl(this._pickupsApi);
  final PickupsAPI _pickupsApi;

  @override
  Future<Either<Failure, String>> confirmPickup({
    required String collectionPointId,
    List<Bag>? bags,
    List<Box>? boxes,
  }) async {
    try {
      final pickupData = PickupMetadata(
        bagIds: bags?.map((e) => SimpleDto(id: e.id!)).toList(),
        boxIds: boxes?.map((e) => SimpleDto(id: e.id)).toList(),
        collectionPointId: collectionPointId,
      );
      final response = await _pickupsApi.addPickup(pickupData);
      final responseDecoded = jsonDecode(response) as Map<String, dynamic>;
      return Right(responseDecoded['pickupId'] as String);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(e, stackTrace: stackTrace),
      );
    } catch (e, stacktrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stacktrace),
      );
    }
  }

  @override
  Future<Either<Failure, List<Pickup>>> fetchPickups({
    required String collectionPointId,
  }) async {
    try {
      final pickups = await _pickupsApi.getPickups(collectionPointId);
      return Right(pickups);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(e, stackTrace: stackTrace),
      );
    } catch (e, stacktrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stacktrace),
      );
    }
  }

  @override
  Future<Either<Failure, Pickup>> getPickupData({
    required String pickupId,
  }) async {
    try {
      final pickupData = await _pickupsApi.getPickupData(pickupId);
      return Right(pickupData);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(e, stackTrace: stackTrace),
      );
    } catch (e, stacktrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stacktrace),
      );
    }
  }
}
