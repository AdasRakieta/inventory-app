part of '../../../ok_mobile_data.dart';

@Injectable(
  as: IBoxRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class BoxRepositoryImpl implements IBoxRepository {
  BoxRepositoryImpl(this._api);
  final BoxAPI _api;

  @override
  Future<Either<Failure, Box>> openNewBox({
    required String boxCode,
    required String collectionPointId,
  }) async {
    try {
      final boxEntity = BoxMetadata(
        boxLabel: boxCode,
        collectionPointId: collectionPointId,
      );
      final response = await _api.openBox(boxEntity);
      final responseDecoded = jsonDecode(response) as Map<String, dynamic>;
      final id = responseDecoded['id'] as String;
      return Right(
        Box(label: boxCode, id: id, dateOpened: DateTime.now(), isOpen: true),
      );
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
  Future<Either<Failure, List<Box>>> fetchOpenBoxes({
    required String collectionPointId,
  }) async {
    try {
      final boxes = await _api.fetchOpenBoxes(collectionPointId);
      return Right(boxes);
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
  Future<Either<Failure, List<Box>>> fetchClosedBoxes({
    required String collectionPointId,
  }) async {
    try {
      final boxes = await _api.fetchClosedBoxes(collectionPointId);
      return Right(boxes);
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
  Future<Either<Failure, Unit?>> addBagsToBox({
    required String boxId,
    required List<String> bagCodes,
  }) async {
    try {
      await _api.addBagsToBox(boxId, {'bagIds': bagCodes});
      return const Right(null);
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
  Future<Either<Failure, Unit?>> removeBagFromBox({
    required String boxId,
    required String bagId,
  }) async {
    try {
      await _api.removeBagFromBox(boxId, bagId);
      return const Right(null);
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
  Future<Either<Failure, Unit?>> closeBoxes(List<String> boxIds) async {
    try {
      await _api.closeBoxes({'boxIds': boxIds});
      return const Right(null);
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
  Future<Either<Failure, Success?>> updateBoxLabel(
    String id, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    try {
      await _api.changeBoxLabel(id, {
        'newLabel': newLabel,
        'reason': reason.jsonKey,
      });
      return const Right(null);
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
}
