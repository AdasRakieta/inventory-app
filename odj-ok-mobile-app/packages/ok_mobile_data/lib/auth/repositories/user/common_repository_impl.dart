part of '../../../ok_mobile_data.dart';

@Injectable(
  as: ICommonRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class CommonRepository implements ICommonRepository {
  CommonRepository(this._commonAPI);

  final CommonAPI _commonAPI;

  @override
  Future<Either<Failure, ContractorUser?>> getCurrentUser() async {
    try {
      final result = await _commonAPI.getCurrentUser();
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
  Future<Either<Failure, RemoteConfiguration>> getRemoteConfiguration() async {
    try {
      final result = await _commonAPI.getRemoteConfiguration(
        DatesHelper.formatToIfModifiedSince(DateTime(2000)),
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
  Future<Either<Failure, ContractorData?>> getCountingCenterData(
    String countingCenterCode,
  ) async {
    try {
      final result = await _commonAPI.getContractorByCode(countingCenterCode);
      return Right(result);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            message: FailureType.wrongDeviceAssignmentToCountingCenter.name,
            severity: FailureSeverity.error,
            type: FailureType.wrongDeviceAssignmentToCountingCenter,
          ),
          on403: () => Failure(
            message: FailureType.wrongUserAssignmentToCountingCenter.name,
            severity: FailureSeverity.error,
            type: FailureType.wrongUserAssignmentToCountingCenter,
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
  Future<Either<Failure, CollectionPointData>> getCollectionPoint(
    String collectionPointId,
    String collectionPointCode,
  ) async {
    try {
      final result = await _commonAPI.getCollectionPointByCode(
        collectionPointId,
        collectionPointCode,
      );
      return Right(result);
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 403) {}
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on403: () => Failure(
            message: FailureType.wrongUserAssignmentToCollectionPoint.name,
            severity: FailureSeverity.error,
            type: FailureType.wrongUserAssignmentToCollectionPoint,
          ),
          on404: () => Failure(
            message: FailureType.wrongDeviceAssignmentToCollectionPoint.name,
            severity: FailureSeverity.error,
            type: FailureType.wrongDeviceAssignmentToCollectionPoint,
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
  Future<Either<Failure, ContractorData>> getCollectionPointContractor(
    String collectionPointCode,
  ) async {
    try {
      final result = await _commonAPI.getContractorByCode(collectionPointCode);
      return Right(result);
    } on DioException catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleDioException(
          e,
          stackTrace: stackTrace,
          on404: () => Failure(
            message: FailureType.wrongDeviceAssignmentToRetailChain.name,
            severity: FailureSeverity.error,
            type: FailureType.wrongDeviceAssignmentToRetailChain,
          ),
          on403: () => Failure(
            message: FailureType.wrongUserAssignmentToRetailChain.name,
            severity: FailureSeverity.error,
            type: FailureType.wrongUserAssignmentToRetailChain,
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
  Future<Either<Failure, void>> acceptTermsAndConditions() async {
    try {
      await _commonAPI.acceptTermsAndConditions();
      return const Right(null);
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 409) {
        return const Right(null);
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
  Future<Either<Failure, Uint8List?>> downloadLogo({
    required String contractorId,
    String? lastModifiedDate,
  }) async {
    try {
      final httpResponse = await _commonAPI.downloadLogoBytes(
        contractorId,
        lastModifiedDate,
      );
      final bytes = httpResponse.data;
      log('Contractor logo downloaded');
      return Right(Uint8List.fromList(bytes));
    } on DioException catch (e, stackTrace) {
      //Response: 304 Not Modified
      //Contractor logo not modified since the date from header.
      if (e.response?.statusCode == 304) {
        log("Contractor logo didn't change since last download");
        return const Right(null);
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
}
