part of '../../ok_mobile_data.dart';

@Injectable(
  as: IAdminRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class AdminRepository extends IAdminRepository {
  AdminRepository();

  final AdminDatasource _adminDatasource = AdminDatasource();

  @override
  Future<Either<Failure, String?>> getPrinter() async {
    try {
      final printer = await _adminDatasource.getPrinter();
      return Right(printer);
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, Unit?>> addPrinter(String macAddress) async {
    try {
      await _adminDatasource.setPrinter(macAddress);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, Unit?>> removePrinter() async {
    try {
      await _adminDatasource.removePrinter();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        ExceptionHelper.handleGeneralException(e, stackTrace: stackTrace),
      );
    }
  }
}
