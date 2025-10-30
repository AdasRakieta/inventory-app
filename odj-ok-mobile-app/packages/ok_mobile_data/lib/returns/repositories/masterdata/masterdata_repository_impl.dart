part of '../../../ok_mobile_data.dart';

@Injectable(
  as: IMasterDataRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class MasterDataRepositoryImpl extends IMasterDataRepository {
  MasterDataRepositoryImpl(this._api);

  final MasterDataAPI _api;

  @override
  Future<Either<Failure, List<Package>>> fetchPackages(
    DateTime? lastModifiedDate,
  ) async {
    try {
      final result = await _api.getMasterData(
        DatesHelper.formatToIfModifiedSince(lastModifiedDate ?? DateTime(2000)),
      );
      await MasterDataDatabase().updateDatabaseWithNewPackages(result);
      return Right(result.map(Package.fromMasterdata).toList());
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 304) {
        return Left(
          ExceptionHelper.handleDioException(
            e,
            stackTrace: stackTrace,
            shouldLog: false,
          ),
        );
      }
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
  Future<Either<Failure, List<Package>>> getPackagesFromDatabase() async {
    try {
      final packages = await MasterDataDatabase().readPackages();
      return Right(packages.map(Package.fromMasterdata).toList());
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }
}
