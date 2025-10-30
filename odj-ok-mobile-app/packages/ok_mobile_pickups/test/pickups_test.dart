import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_pickups/ok_mobile_pickups.dart';
import 'package:ok_mobile_translations/generated/l10n.dart';

class MockPickupsUsecases extends Mock implements PickupsUsecases {}

class MockDeviceConfigUsecases extends Mock implements DeviceConfigUsecases {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PickupsCubit tests', () {
    late PickupsCubit pickupsCubit;
    late MockPickupsUsecases mockPickupsUsecases;
    late MockDeviceConfigUsecases mockDeviceConfigUsecases;

    late Failure failure;
    late Bag testBag1;
    late Bag testBag2;
    late Pickup testPickup1;
    late Pickup testPickup2;

    setUpAll(() async {
      await initializeDateFormatting('en');
      await S.load(const Locale('en'));

      // those 2 methods are needed for printVoucher test to work
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'requestPermissions') {
                return {1: 1};
              }
              return null;
            },
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('ok_mobile_zebra_printer'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'printVoucher') {
                return 'true';
              }
              return null;
            },
          );

      registerFallbackValue(
        const Bag(
          id: 'bagId',
          label: 'bagLabel',
          type: BagType.plastic,
          state: BagState.open,
          packages: [],
        ),
      );
    });

    setUp(() {
      mockPickupsUsecases = MockPickupsUsecases();
      mockDeviceConfigUsecases = MockDeviceConfigUsecases();

      pickupsCubit = PickupsCubit(
        mockPickupsUsecases,
        mockDeviceConfigUsecases,
      );

      testBag1 = const Bag(
        id: 'bagId1',
        label: 'Test Bag 1',
        type: BagType.plastic,
        state: BagState.open,
        packages: [],
      );

      testBag2 = const Bag(
        id: 'bagId2',
        label: 'Test Bag 2',
        type: BagType.can,
        packages: [],
        seal: '123456',
      );

      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
        message: 'failure',
      );

      testPickup1 = Pickup(
        id: 'pickupId1',
        code: 'OD 123456',
        status: PickupStatus.released,
        dateAdded: DateTime(2025, 3, 4),
        bags: [testBag2],
      );
      testPickup2 = Pickup(
        id: 'pickupId2',
        code: 'OD 654321',
        status: PickupStatus.received,
        dateAdded: DateTime(2025, 4, 22),
        bags: [testBag2],
      );

      const testCollectionPointData = CollectionPointData(
        id: 'collectionPointId',
        code: 'CP 123',
        name: 'Test Collection Point',
        segregatesItems: false,
        countingCenter: CountingCenterData(
          id: 'countingCenterId',
          code: 'CC 456',
          nip: '1234567890',
          name: 'Test Counting Center',
          addressStreet: '123 Test St',
          addressBuilding: 'Building A',
          addressApartment: '1A',
          addressPostalCode: '12345',
          addressMunicipality: 'Test Municipality',
          addressCity: 'Test City',
        ),
        collectedPackagingType: CollectedPackagingTypeEnum.allTypes,
      );

      const testContractorData = ContractorData(
        id: 'contractorId',
        code: 'TSTRETAIL',
        name: 'Test Contractor',
        nip: '1234567890',
        addressStreet: '123 Contractor St',
        addressBuilding: 'Building B',
        addressApartment: '2B',
        addressPostalCode: '54321',
        addressMunicipality: 'Contractor Municipality',
        addressCity: 'Contractor City',
      );

      when(
        () => mockDeviceConfigUsecases.collectionPointContractorData,
      ).thenReturn(testContractorData);

      when(
        () => mockDeviceConfigUsecases.collectionPointData,
      ).thenReturn(testCollectionPointData);
    });

    blocTest<PickupsCubit, PickupsState>(
      'emits state with updated selectedBags in reversed order when '
      'addBagToPickup is called',
      build: () => pickupsCubit,
      seed: () => PickupsState.initial().copyWith(selectedBags: [testBag1]),
      act: (cubit) {
        cubit.addBagToPickup(testBag2);
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.selectedBags,
          'selectedBags',
          [testBag2, testBag1],
        ),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with updated selectedBags when removeBagFromPickup '
      'is called',
      build: () => pickupsCubit,
      seed: () =>
          PickupsState.initial().copyWith(selectedBags: [testBag1, testBag2]),
      act: (cubit) {
        cubit.removeBagFromPickup(testBag1);
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.selectedBags,
          'selectedBags',
          [testBag2],
        ),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with cleared result when clearResult is called',
      build: () => pickupsCubit,
      seed: () => PickupsState.initial().copyWith(result: const Success()),
      act: (cubit) {
        cubit.clearResult();
      },
      expect: () => [
        isA<PickupsState>().having((state) => state.result, 'result', isNull),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits loading and loaded states with success when confirmPickup is '
      'called with valid bags',
      build: () => pickupsCubit,
      seed: () {
        return PickupsState.initial().copyWith(
          selectedBags: [testBag1, testBag2],
        );
      },
      setUp: () {
        when(
          () => mockPickupsUsecases.confirmPickup(
            selectedBags: [testBag1, testBag2],
            collectionPointId: 'collectionPointId',
          ),
        ).thenAnswer((_) async => const Right('pickupId'));
        when(
          () => mockPickupsUsecases.getPickupData(pickupId: 'pickupId'),
        ).thenAnswer((_) async => Right(testPickup1));
      },
      act: (cubit) async {
        final result = await cubit.confirmPickupAndPrintDocument('macAddress');
        expect(result, 'pickupId');
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having((state) => state.state, 'state', GeneralState.loading)
            .having(
              (state) => state.selectedPickup?.id,
              'selectedPickup.id',
              isNull,
            ),
        isA<PickupsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.selectedPickup,
              'selectedPickup',
              testPickup1,
            ),
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loaded,
        ),
        isA<PickupsState>()
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.pickup_confirmed),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.selectedBags, 'selectedBags', isEmpty),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with failure result when confirmPickup fails',
      build: () => pickupsCubit,
      seed: () {
        return PickupsState.initial().copyWith(
          selectedBags: [testBag1, testBag2],
        );
      },
      setUp: () {
        when(
          () => mockPickupsUsecases.confirmPickup(
            selectedBags: [testBag1, testBag2],
            collectionPointId: 'collectionPointId',
          ),
        ).thenAnswer((_) async => Left(failure));
      },
      act: (cubit) async {
        final result = await cubit.confirmPickupAndPrintDocument('macAddress');
        expect(result, isNull);
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with updated pickups when fetchPickups is called'
      ' successfully',
      build: () => pickupsCubit,
      setUp: () {
        when(
          () => mockPickupsUsecases.fetchPickups(any()),
        ).thenAnswer((_) async => Right([testPickup1, testPickup2]));
      },
      act: (cubit) async {
        await cubit.fetchPickups();
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having((state) => state.pickups, 'pickups', [
              testPickup2,
              testPickup1,
            ])
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with empty pickups when fetchPickups returns an empty list',
      build: () => pickupsCubit,
      setUp: () {
        when(
          () => mockPickupsUsecases.fetchPickups(any()),
        ).thenAnswer((_) async => const Right([]));
      },
      act: (cubit) async {
        await cubit.fetchPickups();
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having((state) => state.pickups, 'pickups', isEmpty)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with failure result when fetchPickups fails',
      build: () => pickupsCubit,
      setUp: () {
        when(
          () => mockPickupsUsecases.fetchPickups(any()),
        ).thenAnswer((_) async => Left(failure));
      },
      act: (cubit) async {
        await cubit.fetchPickups();
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );
    blocTest<PickupsCubit, PickupsState>(
      'emits state with updated selectedPickup when getPickupData is called'
      ' successfully',
      build: () => pickupsCubit,
      setUp: () {
        when(
          () => mockPickupsUsecases.getPickupData(pickupId: testPickup1.id!),
        ).thenAnswer((_) async => Right(testPickup1));
      },
      act: (cubit) async {
        await cubit.getPickupData(testPickup1.id!);
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having(
              (state) => state.selectedPickup,
              'selectedPickup',
              testPickup1,
            )
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<PickupsCubit, PickupsState>(
      'emits state with failure result when getPickupData fails',
      build: () => pickupsCubit,
      setUp: () {
        when(
          () => mockPickupsUsecases.getPickupData(pickupId: testPickup1.id!),
        ).thenAnswer((_) async => Left(failure));
      },
      act: (cubit) async {
        await cubit.getPickupData(testPickup1.id!);
      },
      expect: () => [
        isA<PickupsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<PickupsState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );
  });
}
