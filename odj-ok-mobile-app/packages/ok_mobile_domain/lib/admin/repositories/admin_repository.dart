part of '../../ok_mobile_domain.dart';

abstract class IAdminRepository {
  Future<Either<Failure, String?>> getPrinter();
  Future<Either<Failure, Unit?>> addPrinter(String macAddress);
  Future<Either<Failure, Unit?>> removePrinter();
}
