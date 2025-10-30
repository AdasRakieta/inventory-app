import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';

class MockIAdminRepository extends Mock implements IAdminRepository {}

void main() {
  late AdminUsecases adminUsecases;
  late MockIAdminRepository mockIAdminRepository;
  const macAddress = '00:11:22:33:44:55';

  setUp(() {
    mockIAdminRepository = MockIAdminRepository();
    adminUsecases = AdminUsecases(mockIAdminRepository);
  });

  group('AdminUsecases success tests', () {
    setUp(() {
      when(
        () => mockIAdminRepository.getPrinter(),
      ).thenAnswer((_) async => const Right(macAddress));

      when(
        () => mockIAdminRepository.addPrinter(macAddress),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => mockIAdminRepository.removePrinter(),
      ).thenAnswer((_) async => const Right(unit));
    });

    test('getPrinter returns mac address on success', () async {
      final result = await adminUsecases.getPrinter();

      expect(result, const Right<Failure, String?>(macAddress));
      verify(() => mockIAdminRepository.getPrinter()).called(1);
    });

    test('addPrinter returns unit on success', () async {
      final result = await adminUsecases.addPrinter(macAddress);

      expect(result, const Right<Failure, Unit?>(null));
      verify(() => mockIAdminRepository.addPrinter(macAddress)).called(1);
    });

    test('removePrinter returns unit on success', () async {
      final result = await adminUsecases.removePrinter();

      expect(result, const Right<Failure, Unit?>(null));
      verify(() => mockIAdminRepository.removePrinter()).called(1);
    });
  });

  group('AdminUsecases errors tests', () {
    const failure = Failure(
      type: FailureType.general,
      message: 'General error',
      severity: FailureSeverity.error,
    );

    setUp(() {
      when(
        () => mockIAdminRepository.getPrinter(),
      ).thenAnswer((_) async => const Left(failure));

      when(
        () => mockIAdminRepository.addPrinter(macAddress),
      ).thenAnswer((_) async => const Left(failure));

      when(
        () => mockIAdminRepository.removePrinter(),
      ).thenAnswer((_) async => const Left(failure));
    });

    test('getPrinter returns failure on error', () async {
      final result = await adminUsecases.getPrinter();

      expect(result, const Left<Failure, String?>(failure));
      verify(() => mockIAdminRepository.getPrinter()).called(1);
    });

    test('addPrinter returns failure on error', () async {
      final result = await adminUsecases.addPrinter(macAddress);

      expect(result, const Left<Failure, String?>(failure));
      verify(() => mockIAdminRepository.addPrinter(macAddress)).called(1);
    });

    test('removePrinter returns failure on error', () async {
      final result = await adminUsecases.removePrinter();

      expect(result, const Left<Failure, String?>(failure));
      verify(() => mockIAdminRepository.removePrinter()).called(1);
    });
  });
}
