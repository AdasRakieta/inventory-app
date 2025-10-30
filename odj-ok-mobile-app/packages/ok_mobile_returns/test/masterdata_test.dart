import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockMasterDataUsecases extends Mock implements MasterDataUsecases {}

void main() {
  group('MasterDataCubit tests', () {
    late MasterDataCubit masterDataCubit;
    late MockMasterDataUsecases mockMasterDataUsecases;

    late Failure failure;
    late Package package1;
    late Package package2;
    late Package package3;

    setUpAll(() async {
      await S.load(const Locale('en'));
    });

    setUp(() {
      mockMasterDataUsecases = MockMasterDataUsecases();
      masterDataCubit = MasterDataCubit(mockMasterDataUsecases);

      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
      );

      package1 = Package(
        eanCode: '123456789',
        description: 'Test Package 1',
        type: BagType.mix,
        quantity: 1,
        deposit: 0.5,
      );
      package2 = Package(
        eanCode: '563456345',
        description: 'Test Package 2',
        type: BagType.plastic,
        quantity: 1,
        deposit: 0.5,
      );
      package3 = Package(
        eanCode: '80787456745',
        description: 'Test Package 3',
        type: BagType.can,
        quantity: 1,
        deposit: 0.5,
      );
    });

    blocTest<MasterDataCubit, MasterDataState>(
      'emits [loading, loaded] with updated packages when fetchMasterData is '
      'successful',
      build: () {
        when(
          () => mockMasterDataUsecases.updateMasterData(),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => mockMasterDataUsecases.packages,
        ).thenReturn([package1, package2, package3]);
        return masterDataCubit;
      },
      act: (cubit) async {
        await cubit.fetchMasterData();
      },
      expect: () => [
        isA<MasterDataState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<MasterDataState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.packages, 'packages', [
              package1,
              package2,
              package3,
            ]),
      ],
    );

    blocTest<MasterDataCubit, MasterDataState>(
      'emits [loading, loaded] with failure when fetchMasterData fails',
      build: () {
        when(
          () => mockMasterDataUsecases.updateMasterData(),
        ).thenAnswer((_) async => Left(failure));
        return masterDataCubit;
      },
      act: (cubit) async {
        await cubit.fetchMasterData();
      },
      expect: () => [
        isA<MasterDataState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<MasterDataState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<MasterDataCubit, MasterDataState>(
      'emits Failure when checkIfCodeIsValid is called with an invalid code',
      build: () {
        when(
          () => mockMasterDataUsecases.getPackageByEan('invalid_code'),
        ).thenReturn(null);
        return masterDataCubit;
      },
      act: (cubit) {
        final result = cubit.getPackageByEan('invalid_code');
        expect(result, isNull);
      },
      expect: () => [
        isA<MasterDataState>().having(
          (state) => state.result,
          'result',
          isA<Failure>().having(
            (failure) => failure.message,
            'message',
            S.current.unknown_ean_code,
          ),
        ),
      ],
    );

    blocTest<MasterDataCubit, MasterDataState>(
      'does not emit Failure when checkIfCodeIsValid is called with '
      'a valid code',
      build: () {
        when(
          () => mockMasterDataUsecases.getPackageByEan(package1.eanCode),
        ).thenReturn(package1);
        return masterDataCubit;
      },
      act: (cubit) {
        final result = cubit.getPackageByEan(package1.eanCode);
        expect(result, package1);
      },
      expect: () => <MasterDataState>[],
    );

    test(
      'returns null when getPackageDescription is called with an invalid code',
      () {
        when(
          () => mockMasterDataUsecases.getPackageDescription('invalid_code'),
        ).thenReturn(null);

        final result = masterDataCubit.getPackageDescription('invalid_code');

        expect(result, isNull);
      },
    );

    test('returns description when getPackageDescription is called with a '
        'valid code', () {
      when(
        () => mockMasterDataUsecases.getPackageDescription(package1.eanCode),
      ).thenReturn(package1.description);

      final result = masterDataCubit.getPackageDescription(package1.eanCode);

      expect(result, package1.description);
    });

    test('returns null when getPackageType is called with an invalid code', () {
      when(
        () => mockMasterDataUsecases.getPackageType('invalid_code'),
      ).thenReturn(null);

      final result = masterDataCubit.getPackageType('invalid_code');

      expect(result, isNull);
    });

    test('returns type when getPackageType is called with a valid code', () {
      when(
        () => mockMasterDataUsecases.getPackageType(package1.eanCode),
      ).thenReturn(package1.type);

      final result = masterDataCubit.getPackageType(package1.eanCode);

      expect(result, package1.type);
    });

    blocTest<MasterDataCubit, MasterDataState>(
      'emits state with null result when clearResult is called',
      build: () => masterDataCubit,
      seed: () => MasterDataState.initial().copyWith(result: failure),
      act: (cubit) {
        cubit.clearResult();
      },
      expect: () => [
        isA<MasterDataState>().having((state) => state.result, 'result', null),
      ],
    );
  });
}
