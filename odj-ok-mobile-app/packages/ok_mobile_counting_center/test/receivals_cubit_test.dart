import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_counting_center/ok_mobile_counting_center.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockReceivalsUsecases extends Mock implements ReceivalsUsecases {}

void main() {
  late ReceivalsCubit receivalsCubit;
  late MockReceivalsUsecases mockReceivalsUsecases;
  late Failure failure;
  late Bag testBag;
  late Pickup testReceival;
  late ReceivalsResponse testReceivalsResponse;

  setUpAll(() async {
    await S.load(const Locale('en'));

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
    mockReceivalsUsecases = MockReceivalsUsecases();
    receivalsCubit = ReceivalsCubit(mockReceivalsUsecases);

    testBag = const Bag(
      id: 'bagId1',
      label: 'Test Bag 1',
      type: BagType.plastic,
      state: BagState.open,
      seal: 'testSeal',
      packages: [],
    );

    failure = const Failure(
      type: FailureType.general,
      severity: FailureSeverity.error,
      message: 'failure',
    );

    testReceival = Pickup(
      id: 'pickupId',
      code: 'pickupCode',
      dateAdded: DateTime.now(),
      dateModified: DateTime.now(),
      status: PickupStatus.released,
      bags: [testBag],
    );

    testReceivalsResponse = ReceivalsResponse(
      ccPickups: [
        CCPickupData(
          id: 'pickupId',
          code: 'pickupCode',
          dateAdded: DateTime.now(),
          dateModified: DateTime.now(),
          status: PickupStatus.released,
        ),
      ],
      packages: const [],
    );
  });

  group('ReceivalsCubit tests', () {
    blocTest<ReceivalsCubit, ReceivalsState>(
      'addBagToReceival emits updated state with new bag',
      build: () => receivalsCubit,
      seed:
          () =>
              ReceivalsState.initial().copyWith(currentReceival: Pickup.empty),
      act: (cubit) {
        cubit.addBagToReceival(testBag);
      },

      expect:
          () => [
            isA<ReceivalsState>()
                .having(
                  (state) => state.currentReceival!.bags,
                  'currentReceival.bags',
                  contains(testBag),
                )
                .having((state) => state.lastAddedBag, 'lastAddedBag', testBag),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'validateBag returns null and emits failure if bag with same seal exists',
      build: () => receivalsCubit,
      seed:
          () => ReceivalsState.initial().copyWith(
            currentReceival: () => testReceival,
          ),
      act: (cubit) async {
        final result = await cubit.validateBag(
          testBag.seal!,
          'countingCenterId',
        );
        expect(result, isNull);
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.result,
              'result',
              Failure(
                type: FailureType.general,
                severity: FailureSeverity.warning,
                message: S.current.bag_already_added_to_receival,
              ),
            ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'validateBag emits loading and loaded states with valid bag',
      build: () {
        when(
          () => mockReceivalsUsecases.validateBag(any(), any()),
        ).thenAnswer((_) async => Right(testBag));
        return receivalsCubit;
      },
      seed:
          () => ReceivalsState.initial().copyWith(
            currentReceival: () => testReceival,
          ),
      act: (cubit) async {
        final result = await cubit.validateBag('123', 'countingCenterId');
        expect(result, testBag);
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loaded,
            ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'validateBag emits loading and loaded states with failure when '
      'bag does not exist',
      build: () {
        when(
          () => mockReceivalsUsecases.validateBag(any(), any()),
        ).thenAnswer((_) async => Left(failure));
        return receivalsCubit;
      },
      seed:
          () => ReceivalsState.initial().copyWith(
            currentReceival: () => testReceival,
          ),
      act: (cubit) async {
        final result = await cubit.validateBag(
          'nonExistingSeal',
          'countingCenterId',
        );
        expect(result, isNull);
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having((state) => state.result, 'result', failure),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'confirmReceival emits loading and loaded states with success',
      build: () {
        when(
          () => mockReceivalsUsecases.confirmReceival([testBag], any()),
        ).thenAnswer((_) async => const Right(202));
        return receivalsCubit;
      },
      seed:
          () => ReceivalsState.initial().copyWith(
            currentReceival: () => testReceival,
          ),
      act: (cubit) async {
        final result = await cubit.confirmReceival('countingCenterId');
        expect(result, isTrue);
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having(
                  (state) => state.currentReceival,
                  'currentReceival',
                  isNull,
                )
                .having(
                  (state) => state.result,
                  'result',
                  Success(message: S.current.packages_receival_confirmation),
                ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'confirmReceival emits loading and loaded states with failure when '
      'confirmation fails',
      build: () {
        when(
          () => mockReceivalsUsecases.confirmReceival([testBag], any()),
        ).thenAnswer((_) async => Left(failure));
        return receivalsCubit;
      },
      seed:
          () => ReceivalsState.initial().copyWith(
            currentReceival: () => testReceival,
          ),
      act: (cubit) async {
        final result = await cubit.confirmReceival('countingCenterId');
        expect(result, isFalse);
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having((state) => state.result, 'result', failure),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'getPlannedReceivals emits loading and loaded states with planned '
      'receivals',
      build: () {
        when(
          () => mockReceivalsUsecases.getPlannedReceivals(any()),
        ).thenAnswer((_) async => Right(testReceivalsResponse));
        return receivalsCubit;
      },
      act: (cubit) async {
        await cubit.getPlannedReceivals('countingCenterId');
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having(
                  (state) => state.plannedReceivals,
                  'plannedReceivals',
                  testReceivalsResponse,
                ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'getPlannedReceivals emits loading and loaded states with failure',
      build: () {
        when(
          () => mockReceivalsUsecases.getPlannedReceivals(any()),
        ).thenAnswer((_) async => Left(failure));
        return receivalsCubit;
      },
      act: (cubit) async {
        await cubit.getPlannedReceivals('countingCenterId');
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having((state) => state.result, 'result', failure),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'startNewReceival emits state with new empty receival when '
      'currentReceival is null',
      build: () => receivalsCubit,
      seed:
          () => ReceivalsState.initial().copyWith(currentReceival: () => null),
      act: (cubit) => cubit.startNewReceival(),
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.currentReceival,
              'currentReceival',
              isNotNull,
            ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'startNewReceival does not emit when currentReceival is not null',
      build: () => receivalsCubit,
      seed:
          () =>
              ReceivalsState.initial().copyWith(currentReceival: Pickup.empty),
      act: (cubit) => cubit.startNewReceival(),
      expect: () => <ReceivalsState>[],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'getCollectedReceivals emits loading and loaded states with collected '
      'receivals',
      build: () {
        when(
          () => mockReceivalsUsecases.getCollectedReceivals(any()),
        ).thenAnswer((_) async => Right(testReceivalsResponse));
        return receivalsCubit;
      },
      act: (cubit) async {
        await cubit.getCollectedReceivals('countingCenterId');
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having(
                  (state) => state.collectedReceivals,
                  'collectedReceivals',
                  testReceivalsResponse,
                ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'getCollectedReceivals emits loading and loaded states with failure',
      build: () {
        when(
          () => mockReceivalsUsecases.getCollectedReceivals(any()),
        ).thenAnswer((_) async => Left(failure));
        return receivalsCubit;
      },
      act: (cubit) async {
        await cubit.getCollectedReceivals('countingCenterId');
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having((state) => state.result, 'result', failure),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'getReceivalData emits loading and loaded states with receival data',
      build: () {
        when(
          () => mockReceivalsUsecases.getReceivalData(pickupId: 'pickupId'),
        ).thenAnswer((_) async => Right(testReceival));
        return receivalsCubit;
      },
      act: (cubit) async {
        await cubit.getReceivalData('pickupId');
      },
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.state,
              'state',
              GeneralState.loading,
            ),
            isA<ReceivalsState>()
                .having((state) => state.state, 'state', GeneralState.loaded)
                .having(
                  (state) => state.selectedReceival,
                  'selectedReceival',
                  testReceival,
                ),
          ],
    );

    blocTest<ReceivalsCubit, ReceivalsState>(
      'clearResult emits state with null result',
      build: () => receivalsCubit,
      seed:
          () => ReceivalsState.initial().copyWith(
            result: () => const Success(message: 'Some message'),
          ),
      act: (cubit) => cubit.clearResult(),
      expect:
          () => [
            isA<ReceivalsState>().having(
              (state) => state.result,
              'result',
              isNull,
            ),
          ],
    );
  });
}
