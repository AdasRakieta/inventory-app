part of '../../ok_mobile_domain.dart';

@lazySingleton
class AdminUsecases {
  AdminUsecases(this._adminRepository);

  final IAdminRepository _adminRepository;

  Future<Either<Failure, String?>> getPrinter() async {
    final result = await _adminRepository.getPrinter();

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (macAddress) {
        return Right(macAddress);
      },
    );
  }

  Future<Either<Failure, Unit?>> addPrinter(String macAddress) async {
    final result = await _adminRepository.addPrinter(macAddress);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (_) {
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, Unit?>> removePrinter() async {
    final result = await _adminRepository.removePrinter();

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (_) {
        return const Right(null);
      },
    );
  }
}
