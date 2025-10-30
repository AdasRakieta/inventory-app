import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_admin/ok_mobile_admin.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockAdminUsecases extends Mock implements AdminUsecases {}

void main() {
  group('AdminCubit tests', () {
    late AdminCubit adminCubit;
    late MockAdminUsecases mockAdminUsecases;

    late Failure failure;
    const macAddress = '00:11:22:33:44:55';

    setUpAll(() async {
      await S.load(const Locale('en'));
    });

    setUp(() async {
      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
      );
      mockAdminUsecases = MockAdminUsecases();
      when(
        () => mockAdminUsecases.getPrinter(),
      ).thenAnswer((_) async => const Right(null));
      adminCubit = AdminCubit(mockAdminUsecases)..emit(AdminState.initial());
    });

    blocTest<AdminCubit, AdminState>(
      'emits [loading, loaded + success] when addPrinter is successful',
      build: () {
        when(
          () => mockAdminUsecases.addPrinter(macAddress),
        ).thenAnswer((_) async => const Right(null));
        return adminCubit;
      },
      act: (cubit) async {
        await cubit.addPrinter(macAddress);
      },
      expect: () => [
        const AdminState(state: GeneralState.loading),
        AdminState(
          state: GeneralState.loaded,
          selectedPrinterMacAddress: macAddress.toUpperCase(),
          result: Success(
            message: S.current.printer_was_chosen(macAddress.toUpperCase()),
          ),
        ),
      ],
    );

    blocTest<AdminCubit, AdminState>(
      'emits [loading, state error + failure] when addPrinter'
      ' fails',
      build: () {
        when(
          () => mockAdminUsecases.addPrinter(macAddress),
        ).thenAnswer((_) async => Left(failure));
        return adminCubit;
      },
      act: (cubit) async {
        await cubit.addPrinter(macAddress);
      },
      expect: () => [
        const AdminState(state: GeneralState.loading),
        AdminState(state: GeneralState.error, result: failure),
      ],
    );

    blocTest<AdminCubit, AdminState>(
      'emits [loading, loaded + success] when removePrinter'
      ' is successful',
      build: () {
        when(
          () => mockAdminUsecases.removePrinter(),
        ).thenAnswer((_) async => const Right(unit));
        return adminCubit;
      },
      act: (cubit) async {
        await cubit.removePrinter();
      },
      expect: () => [
        const AdminState(state: GeneralState.loading),
        AdminState(
          state: GeneralState.loaded,
          result: Success(message: S.current.removed_last_printer),
        ),
      ],
    );

    blocTest<AdminCubit, AdminState>(
      'emits [loading, state error + failure] when removePrinter fails',
      build: () {
        when(
          () => mockAdminUsecases.removePrinter(),
        ).thenAnswer((_) async => Left(failure));

        return adminCubit;
      },
      seed: () =>
          AdminState.initial().copyWith(selectedPrinterMacAddress: macAddress),
      act: (cubit) async {
        await cubit.removePrinter();
      },
      expect: () => [
        const AdminState(
          state: GeneralState.loading,
          selectedPrinterMacAddress: macAddress,
        ),
        AdminState(
          selectedPrinterMacAddress: macAddress,
          state: GeneralState.error,
          result: failure,
        ),
      ],
    );

    blocTest<AdminCubit, AdminState>(
      'emits state with cleared result when clearResult is called',
      build: () => adminCubit,
      seed: () => AdminState.initial().copyWith(
        selectedPrinterMacAddress: macAddress,
        result: failure,
      ),
      act: (cubit) => cubit.clearResult(),
      expect: () => [
        AdminState.initial().copyWith(selectedPrinterMacAddress: macAddress),
      ],
    );
  });
}
