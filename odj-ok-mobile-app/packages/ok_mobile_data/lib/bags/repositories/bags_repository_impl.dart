part of '../../../ok_mobile_data.dart';

@Injectable(
  as: IBagsRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class BagsRepositoryImpl implements IBagsRepository {
  BagsRepositoryImpl(this._api);
  final BagsAPI _api;

  @override
  Future<Either<Failure, List<Bag>>> fetchOpenBags({
    required String collectionPointId,
  }) async {
    try {
      final bags = await _api.fetchOpenBags(collectionPointId);
      return Right(bags);
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
  Future<Either<Failure, List<Bag>>> fetchClosedBags({
    required String collectionPointId,
  }) async {
    try {
      final bags = await _api.fetchClosedBags(collectionPointId);
      return Right(bags);
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
  Future<Either<Failure, Bag>> addBag(BagMetadata bag) async {
    try {
      final response = await _api.openNewBag(bag);
      final dataDecoded = jsonDecode(response) as Map<String, dynamic>;
      final bagWithId = Bag.fromMetadata(bag, dataDecoded['id'] as String);

      return Right(bagWithId);
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
  Future<Either<Failure, Unit?>> addPackage(Package package) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> updateBagLabel(
    String bagId, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    try {
      await _api.changeBag(bagId, {
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

  @override
  Future<Either<Failure, Unit?>> updateBagSeal(
    String bagId, {
    required String newSeal,
    required ActionReason reason,
  }) async {
    try {
      await _api.changeBag(bagId, {
        'newSeal': newSeal,
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

  @override
  Future<Either<Failure, Unit?>> updateBag(
    String bagId, {
    required String newLabel,
    required String newSeal,
    required ActionReason reason,
  }) async {
    try {
      await _api.changeBag(bagId, {
        'newLabel': newLabel,
        'newSeal': newSeal,
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

  @override
  Future<Either<Failure, Unit?>> closeAndSealBag(
    String bagId, {
    required String seal,
  }) async {
    try {
      await _api.closeAndSealBag(bagId, {'seal': seal});
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
