import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/generated/l10n.dart';

class MockBagsUsecases extends Mock implements BagsUsecases {}

void main() {
  group('BagsCubit tests', () {
    late BagsCubit bagsCubit;
    late MockBagsUsecases mockBagsUsecases;

    late Failure failure;
    late Bag openBagPet;
    late Bag closedBagCan;
    late Bag bagAssignedToBox;

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

      registerFallbackValue(
        const BagMetadata(
          label: 'bagLabel',
          collectionPointId: 'collectionPointId',
          type: 'plastic',
        ),
      );

      registerFallbackValue(BagState.open);
      registerFallbackValue(BagType.mix);
      registerFallbackValue(ActionReason.unreadableLabel);
    });

    setUp(() {
      mockBagsUsecases = MockBagsUsecases();
      bagsCubit = BagsCubit(mockBagsUsecases);
      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
        message: 'failure',
      );
      openBagPet = const Bag(
        id: 'bagId 1',
        label: 'test bag 1',
        type: BagType.plastic,
        state: BagState.open,
        packages: [],
      );
      closedBagCan = const Bag(
        id: 'bagId 2',
        label: 'test bag 2',
        type: BagType.can,
        packages: [],
        seal: 'seal',
      );
      bagAssignedToBox = const Bag(
        id: 'bagId 3',
        label: 'test bag 3',
        type: BagType.can,
        boxId: 'boxId',
        packages: [],
      );
    });

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + allBags] when fetchAllBags is successful',
      build: () {
        when(
          () => mockBagsUsecases.fetchOpenBags(),
        ).thenAnswer((_) async => Right([openBagPet]));
        when(
          () => mockBagsUsecases.fetchClosedBags(),
        ).thenAnswer((_) async => Right([closedBagCan]));
        return bagsCubit;
      },
      act: (cubit) async {
        await cubit.fetchAllBags();
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loading)
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty),
        isA<BagsState>()
            .having((state) => state.allBags, 'allBags', contains(closedBagCan))
            .having(
              (state) => state.closedBags,
              'closedBags',
              contains(closedBagCan),
            )
            .having((state) => state.state, 'state', GeneralState.loaded),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loading)
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty),
        isA<BagsState>()
            .having((state) => state.allBags, 'allBags', contains(openBagPet))
            .having((state) => state.openBags, 'openBags', contains(openBagPet))
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when fetchAllBags fails',
      build: () {
        when(
          () => mockBagsUsecases.fetchOpenBags(),
        ).thenAnswer((_) async => Left(failure));
        when(
          () => mockBagsUsecases.fetchClosedBags(),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        await cubit.fetchAllBags();
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loading)
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loading)
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + bags] when fetchOpenBags is successful',
      build: () {
        when(
          () => mockBagsUsecases.fetchOpenBags(),
        ).thenAnswer((_) async => Right([openBagPet]));
        return bagsCubit;
      },
      act: (cubit) async {
        await cubit.fetchOpenBags();
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty)
            .having((state) => state.state, 'state', GeneralState.loading),
        isA<BagsState>()
            .having((state) => state.openBags, 'openBags', contains(openBagPet))
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when fetchOpenBags fails',
      build: () {
        when(
          () => mockBagsUsecases.fetchOpenBags(),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        await cubit.fetchOpenBags();
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty)
            .having((state) => state.state, 'state', GeneralState.loading),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + closedBags] when fetchClosedBags is successful',
      build: () {
        when(
          () => mockBagsUsecases.fetchClosedBags(),
        ).thenAnswer((_) async => Right([closedBagCan]));
        return bagsCubit;
      },
      act: (cubit) async {
        await cubit.fetchClosedBags();
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty)
            .having((state) => state.state, 'state', GeneralState.loading),
        isA<BagsState>()
            .having((state) => state.closedBags, 'closedBags', [closedBagCan])
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when fetchClosedBags fails',
      build: () {
        when(
          () => mockBagsUsecases.fetchClosedBags(),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        await cubit.fetchClosedBags();
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty)
            .having((state) => state.state, 'state', GeneralState.loading),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'state', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + success] when openNewBag is successful',
      build: () {
        when(
          () => mockBagsUsecases.addBag(any()),
        ).thenAnswer((_) async => Right(openBagPet.copyWith(id: 'new_id')));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.openNewBag(
          bagType: BagType.plastic,
          bagLabel: 'test bag 1',
          collectionPointId: 'collection_point_id',
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having(
              (state) => state.currentReturnSelectedBag,
              'selectedBag',
              openBagPet.copyWith(id: 'new_id'),
            )
            .having(
              (state) => state.openBags,
              'openBags',
              contains(openBagPet.copyWith(id: 'new_id')),
            )
            .having(
              (state) => state.result,
              'result',
              Success(
                message: S.current.new_bag_properly_opened(openBagPet.label),
              ),
            )
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when openNewBag fails',
      build: () {
        when(
          () => mockBagsUsecases.addBag(any()),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.openNewBag(
          bagType: BagType.plastic,
          bagLabel: 'bagLabel',
          collectionPointId: 'collection_point_id',
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBag when selectBag is called',
      build: () => bagsCubit,
      act: (cubit) {
        cubit.selectBag(bag: openBagPet);
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.selectedBag, 'selectedBag', openBagPet)
            .having((state) => state.result, 'result', isNull),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBag + success when selectBag is called with '
      'showSnackBar flag turned on',
      build: () => bagsCubit,
      act: (cubit) {
        cubit.selectBag(bag: openBagPet, showSnackBar: true);
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.selectedBag, 'selectedBag', openBagPet)
            .having(
              (state) => state.result,
              'result',
              Success(
                message: S.current.bag_was_chosen_with_type(
                  openBagPet.label,
                  openBagPet.type.localisedName,
                ),
              ),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with cleared selectedBag when clearSelectedBag is called',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(selectedBag: () => openBagPet),
      act: (cubit) {
        cubit.clearSelectedBag();
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.selectedBag,
          'selectedBag',
          isNull,
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBag when selectBagById is called with '
      'a valid ID',
      build: () {
        when(
          () => mockBagsUsecases.getBagById(openBagPet.id!),
        ).thenReturn(openBagPet);
        return bagsCubit;
      },
      act: (cubit) {
        final result = cubit.selectBagById(openBagPet.id!);
        expect(result, openBagPet);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.selectedBag,
          'selectedBag',
          openBagPet,
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with no selectedBag when selectBagById is called with '
      'an invalid ID',
      build: () {
        when(() => mockBagsUsecases.getBagById(any())).thenReturn(null);
        return bagsCubit;
      },
      act: (cubit) {
        final result = cubit.selectBagById(openBagPet.id!);
        expect(result, isNull);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBag when selectBagByLabel is called with '
      'a valid label',
      build: () {
        when(
          () => mockBagsUsecases.getBagByLabel(openBagPet.label),
        ).thenReturn(openBagPet);
        return bagsCubit;
      },
      act: (cubit) {
        final result = cubit.getBagByLabel(
          openBagPet.label,
          successMessage: S.current.bag_correctly_chosen,
        );
        expect(result, openBagPet);
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.selectedBag, 'selectedBag', openBagPet)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.bag_correctly_chosen),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBag + success when selectBagByLabel is called '
      'with a valid label and showSnackBar flag turned on',
      build: () {
        when(
          () => mockBagsUsecases.getBagByLabel(openBagPet.label),
        ).thenReturn(openBagPet);
        return bagsCubit;
      },
      act: (cubit) {
        final result = cubit.getBagByLabel(
          openBagPet.label,
          successMessage: S.current.bag_correctly_chosen,
        );
        expect(result, openBagPet);
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.selectedBag, 'selectedBag', openBagPet)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.bag_correctly_chosen),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with failure when selectBagByLabel is '
      'called with an invalid label',
      build: () {
        when(() => mockBagsUsecases.getBagByLabel(any())).thenReturn(null);
        return bagsCubit;
      },
      act: (cubit) {
        final result = cubit.getBagByLabel(
          openBagPet.label,
          successMessage: S.current.bag_correctly_chosen,
        );
        expect(result, isNull);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [bag list] when getBagsAndSaveToState finds bags '
      'corresponding to the filtering',
      build: () {
        when(
          () => mockBagsUsecases.getBags(
            selectedStates: [BagState.open],
            selectedTypes: [BagType.can],
          ),
        ).thenReturn([openBagPet]);
        return bagsCubit;
      },
      act: (cubit) async {
        cubit.getBagsAndSaveToState(
          selectedStates: [BagState.open],
          selectedTypes: [BagType.can],
        );
      },
      expect: () => [
        isA<BagsState>()
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              contains(openBagPet),
            )
            .having(
              (state) => state.selectedBagStates,
              'selectedBagStates',
              contains(BagState.open),
            )
            .having(
              (state) => state.selectedBagTypes,
              'selectedBagTypes',
              contains(BagType.can),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [empty list] when getBagsAndSaveToState finds no bags that '
      'correspond to the filtering',
      build: () {
        when(
          () => mockBagsUsecases.getBags(
            selectedStates: [BagState.closed],
            selectedTypes: [BagType.plastic],
          ),
        ).thenReturn([]);
        return bagsCubit;
      },
      act: (cubit) async {
        cubit.getBagsAndSaveToState(
          selectedStates: [BagState.closed],
          selectedTypes: [BagType.plastic],
        );
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.bagsToShow, 'bagsToShow', isEmpty)
            .having(
              (state) => state.selectedBagStates,
              'selectedBagStates',
              contains(BagState.closed),
            )
            .having(
              (state) => state.selectedBagTypes,
              'selectedBagTypes',
              contains(BagType.plastic),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with chosen BagType removed from selectedBagTypes when '
      'type was previously selected',
      build: () {
        when(
          () => mockBagsUsecases.getBags(
            selectedStates: any<List<BagState>>(named: 'selectedStates'),
            selectedTypes: any<List<BagType>>(named: 'selectedTypes'),
          ),
        ).thenReturn([openBagPet]);
        return bagsCubit;
      },
      seed: () =>
          BagsState.initial().copyWith(selectedBagTypes: [BagType.plastic]),
      act: (cubit) {
        cubit.changeTypeFilter(type: BagType.plastic);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.selectedBagTypes,
          'selectedBagTypes',
          isNot(contains(BagType.plastic)),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with chosen BagType added to selectedBagTypes when '
      'chosen BagType was not previously selected',
      build: () {
        when(
          () => mockBagsUsecases.getBags(
            selectedStates: any<List<BagState>>(named: 'selectedStates'),
            selectedTypes: any<List<BagType>>(named: 'selectedTypes'),
          ),
        ).thenReturn([openBagPet]);
        return bagsCubit;
      },
      seed: () => BagsState.initial().copyWith(selectedBagTypes: [BagType.can]),
      act: (cubit) {
        cubit.changeTypeFilter(type: BagType.plastic);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.selectedBagTypes,
          'selectedBagTypes',
          contains(BagType.plastic),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + success + label updated] when updateBagLabel '
      'is successful for an open bag',
      build: () {
        when(
          () => mockBagsUsecases.updateBagLabel(
            openBagPet.id!,
            newLabel: 'newLabel',
            reason: any(named: 'reason'),
          ),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.label_has_been_changed)),
        );
        when(
          () => mockBagsUsecases.openBags,
        ).thenReturn([openBagPet.copyWith(label: 'newLabel')]);
        when(() => mockBagsUsecases.closedBags).thenReturn([closedBagCan]);
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBagLabel(
          openBagPet.id!,
          newLabel: 'newLabel',
          reason: ActionReason.unreadableLabel,
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having(
              (state) => state.openBags,
              'state.openBags',
              contains(openBagPet.copyWith(label: 'newLabel')),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.label_has_been_changed),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + success + label updated] when updateBagLabel '
      'is successful for a closed bag',
      build: () {
        when(
          () => mockBagsUsecases.updateBagLabel(
            closedBagCan.id!,
            newLabel: 'newLabel',
            reason: any(named: 'reason'),
          ),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.label_has_been_changed)),
        );
        when(() => mockBagsUsecases.openBags).thenReturn([openBagPet]);
        when(
          () => mockBagsUsecases.closedBags,
        ).thenReturn([closedBagCan.copyWith(label: 'newLabel')]);
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBagLabel(
          closedBagCan.id!,
          newLabel: 'newLabel',
          reason: ActionReason.unreadableLabel,
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having(
              (state) => state.closedBags,
              'state.closedBags',
              contains(closedBagCan.copyWith(label: 'newLabel')),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.label_has_been_changed),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when updateBagLabel fails',
      build: () {
        when(
          () => mockBagsUsecases.updateBagLabel(
            openBagPet.id!,
            newLabel: 'newLabel',
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBagLabel(
          openBagPet.id!,
          newLabel: 'newLabel',
          reason: ActionReason.damagedLabel,
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + success + seal updated] when updateBagSeal '
      'is successful',
      build: () {
        when(
          () => mockBagsUsecases.updateBagSeal(
            closedBagCan.id!,
            newSeal: 'newSeal',
            reason: any(named: 'reason'),
          ),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.seal_changed_succesfully)),
        );
        when(
          () => mockBagsUsecases.getBagById(closedBagCan.id!),
        ).thenReturn(closedBagCan.copyWith(seal: () => 'newSeal'));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBagSeal(
          closedBagCan.id!,
          newSeal: 'newSeal',
          reason: ActionReason.damagedSeal,
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having(
              (state) => state.selectedBag!.seal,
              'selectedBag.seal',
              'newSeal',
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.seal_changed_succesfully),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when updateBagSeal fails',
      build: () {
        when(
          () => mockBagsUsecases.updateBagSeal(
            openBagPet.id!,
            newSeal: 'newSeal',
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBagSeal(
          openBagPet.id!,
          newSeal: 'newSeal',
          reason: ActionReason.damagedSeal,
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + success] when updateBag is successful',
      build: () {
        when(
          () => mockBagsUsecases.updateBag(
            closedBagCan.id!,
            newLabel: any(named: 'newLabel'),
            newSeal: any(named: 'newSeal'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.label_and_seal_changed)),
        );
        when(
          () => mockBagsUsecases.closedBags,
        ).thenReturn([closedBagCan.copyWith(label: 'new_label')]);
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBag(
          closedBagCan.id!,
          newLabel: 'new_label',
          newSeal: 'new_seal',
          reason: ActionReason.tornBag,
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having(
              (state) => state.closedBags,
              'closedBags',
              contains(closedBagCan.copyWith(label: 'new_label')),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.label_and_seal_changed),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when updateBag fails',
      build: () {
        when(
          () => mockBagsUsecases.updateBag(
            openBagPet.id!,
            newLabel: any(named: 'newLabel'),
            newSeal: any(named: 'newSeal'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.updateBag(
          openBagPet.id!,
          newLabel: 'new_label',
          newSeal: 'new_seal',
          reason: ActionReason.tornBag,
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'returns a list of closedBags filtered by IDs when getClosedBagsByIds '
      'is called',
      build: () => bagsCubit,
      seed: () {
        final closedBag1 = closedBagCan.copyWith(id: 'closedBagId1');
        final closedBag2 = closedBagCan.copyWith(id: 'closedBagId2');
        return BagsState.initial().copyWith(
          closedBags: [closedBagCan, closedBag1, closedBag2],
        );
      },
      act: (cubit) {
        final result = cubit.getClosedBagsByIds([
          'closedBagId1',
          'closedBagId2',
        ]);
        expect(result, [
          closedBagCan.copyWith(id: 'closedBagId1'),
          closedBagCan.copyWith(id: 'closedBagId2'),
        ]);
      },
      expect: () => <BagsState>[],
    );

    blocTest<BagsCubit, BagsState>(
      'returns empty list when getClosedBagsByIds is called with '
      'non-matching IDs',
      build: () => bagsCubit,
      seed: () {
        final closedBag1 = closedBagCan.copyWith(id: 'closedBagId1');
        final closedBag2 = closedBagCan.copyWith(id: 'closedBagId2');
        return BagsState.initial().copyWith(
          closedBags: [closedBagCan, closedBag1, closedBag2],
        );
      },
      act: (cubit) {
        final result = cubit.getClosedBagsByIds(['nonMatchingId']);
        expect(result, isEmpty);
      },
      expect: () => <BagsState>[],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + success + seal added] when closeAndSealBag '
      'is successful',
      build: () {
        when(
          () =>
              mockBagsUsecases.closeAndSealBag(openBagPet.id!, seal: 'newSeal'),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.seal_added_successfully)),
        );
        when(
          () => mockBagsUsecases.getBagById(openBagPet.id!),
        ).thenAnswer((_) => openBagPet.copyWith(seal: () => 'newSeal'));
        when(() => mockBagsUsecases.openBags).thenAnswer((_) => []);
        when(() => mockBagsUsecases.closedBags).thenAnswer((_) => []);
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.closeAndSealBag(
          openBagPet.id!,
          seal: 'newSeal',
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having(
              (state) => state.selectedBag!.seal,
              'selectedBag.seal',
              'newSeal',
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.seal_added_successfully),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits [loading, loaded + failure] when closeAndSealBag fails',
      build: () {
        when(
          () =>
              mockBagsUsecases.closeAndSealBag(openBagPet.id!, seal: 'newSeal'),
        ).thenAnswer((_) async => Left(failure));
        return bagsCubit;
      },
      act: (cubit) async {
        final result = await cubit.closeAndSealBag(
          openBagPet.id!,
          seal: 'newSeal',
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BagsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );
    blocTest<BagsCubit, BagsState>(
      'checkIfClosedBagExists returns correct bag when bag exists and is not '
      'assigned to a box',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(closedBags: [closedBagCan]),
      act: (cubit) async {
        final result = cubit.checkIfClosedBagExists(closedBagCan.label);
        expect(result, closedBagCan);
      },
      expect: () => <BagsState>[],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfClosedBagExists emits failure when bag exists but is '
      'assigned to a box',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(closedBags: [bagAssignedToBox]),
      act: (cubit) async {
        final result = cubit.checkIfClosedBagExists(bagAssignedToBox.label);
        expect(result, isNull);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.bagAlreadyAddedToBox,
            severity: FailureSeverity.warning,
            message: S.current.bag_already_added_to_box,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfClosedBagExists emits failure when no bag is found',
      build: () => bagsCubit,
      act: (cubit) {
        final result = cubit.checkIfClosedBagExists(closedBagCan.label);
        expect(result, isNull);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfAssignedToBox returns true and emits failure when bag is '
      'assigned to a box',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(closedBags: [bagAssignedToBox]),
      act: (cubit) {
        final result = cubit.checkIfAssignedToBox(bagAssignedToBox);
        expect(result, isTrue);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.bagAlreadyAddedToBox,
            severity: FailureSeverity.warning,
            message: S.current.bag_already_added_to_box,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfAssignedToBox returns false when bag is not assigned to a box',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(closedBags: [closedBagCan]),
      act: (cubit) {
        final result = cubit.checkIfAssignedToBox(closedBagCan);
        expect(result, isFalse);
      },
      expect: () => <BagsState>[],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBags when selectBags is called',
      build: () => bagsCubit,
      act: (cubit) {
        cubit.selectBags([openBagPet, closedBagCan]);
      },
      expect: () => [
        isA<BagsState>().having((state) => state.selectedBags, 'selectedBags', [
          openBagPet,
          closedBagCan,
        ]),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with selectedBags updated when unselectBag is called',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
        bagsToShow: [openBagPet, closedBagCan],
        bagsToAddToBox: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.unselectBag(openBagPet);
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.selectedBags, 'selectedBags', [
              closedBagCan,
            ])
            .having((state) => state.bagsToShow, 'bagsToShow', [closedBagCan])
            .having((state) => state.bagsToAddToBox, 'bagsToAddToBox', [
              closedBagCan,
            ])
            .having(
              (state) => state.selectedBags,
              'selectedBags',
              isNot(contains(openBagPet)),
            )
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              isNot(contains(openBagPet)),
            )
            .having(
              (state) => state.bagsToAddToBox,
              'bagsToAddToBox',
              isNot(contains(openBagPet)),
            ),
      ],
    );
    blocTest<BagsCubit, BagsState>(
      'adds only bags with selected BagType from bags to bags to show when '
      'filterSelectedBags is called with value true',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.filterSelectedBags(BagType.can, value: true);
      },
      expect: () => [
        isA<BagsState>()
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              contains(closedBagCan),
            )
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              isNot(contains(openBagPet)),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'does not add selected BagType bags to bags to show when '
      'filterSelectedBags is called with value false',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.filterSelectedBags(BagType.plastic, value: false);
      },
      expect: () => [
        isA<BagsState>()
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              isNot(contains(closedBagCan)),
            )
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              isNot(contains(openBagPet)),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'adds selected BagType bags to bags to show when filterSelectedBags is '
      'called with value true and does not alter previously selected bags',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
        bagsToShow: [closedBagCan],
      ),
      act: (cubit) {
        cubit.filterSelectedBags(BagType.plastic, value: true);
      },
      expect: () => [
        isA<BagsState>()
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              contains(closedBagCan),
            )
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              contains(openBagPet),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'does not add selected BagType bags to bags to show when '
      'filterSelectedBags is called with value false and does not alter '
      'previously selected bags',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
        bagsToShow: [closedBagCan],
      ),
      act: (cubit) {
        cubit.filterSelectedBags(BagType.plastic, value: false);
      },
      expect: () => [
        isA<BagsState>()
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              contains(closedBagCan),
            )
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              isNot(contains(openBagPet)),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'removes selected BagType bags from bags to show when '
      'filterSelectedBags is called with value false and bags of this type are '
      'already present in bags to show',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
        bagsToShow: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.filterSelectedBags(BagType.plastic, value: false);
      },
      expect: () => [
        isA<BagsState>()
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              contains(closedBagCan),
            )
            .having(
              (state) => state.bagsToShow,
              'bagsToShow',
              isNot(contains(openBagPet)),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with empty bagsToShow when filterSelectedBags is called with'
      ' no matching bags in selectedBags',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(selectedBags: [closedBagCan]),
      act: (cubit) {
        cubit.filterSelectedBags(BagType.plastic, value: true);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.bagsToShow,
          'bagsToShow',
          isEmpty,
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with warning when issueWarning is called',
      build: () => bagsCubit,
      act: (cubit) {
        cubit.issueWarning('This is a warning');
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          const Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: 'This is a warning',
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with confirmation result when showConfirmation is called',
      build: () => bagsCubit,
      act: (cubit) {
        cubit.showConfirmation('This is a confirmation');
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          const Success(message: 'This is a confirmation'),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfClosedBagExistsBySeal returns correct bag when bag exists and is '
      'not assigned to a box',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(closedBags: [closedBagCan]),
      act: (cubit) async {
        final result = cubit.checkIfClosedBagExistsBySeal(closedBagCan.seal!);
        expect(result, closedBagCan);
      },
      expect: () => <BagsState>[],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfClosedBagExistsBySeal returns null and emits failure when bag'
      ' exists but is assigned to a box',
      build: () => bagsCubit,
      seed: () {
        return BagsState.initial().copyWith(
          closedBags: [closedBagCan.copyWith(boxId: 'boxId')],
        );
      },
      act: (cubit) {
        final result = cubit.checkIfClosedBagExistsBySeal(closedBagCan.seal!);
        expect(result, isNull);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.bagAlreadyAddedToBox,
            severity: FailureSeverity.warning,
            message: S.current.bag_already_added_to_box,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'checkIfClosedBagExistsBySeal returns null and emits a failure when no '
      'bag is found',
      build: () => bagsCubit,
      seed: () {
        return BagsState.initial().copyWith(closedBags: []);
      },
      act: (cubit) {
        final result = cubit.checkIfClosedBagExistsBySeal(closedBagCan.seal!);
        expect(result, isNull);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_seal_number,
          ),
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with updated bagsToAddToBox when removeBagFromBoxList is '
      'called',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        bagsToAddToBox: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.removeBagFromBoxList(openBagPet);
      },
      expect: () => [
        isA<BagsState>()
            .having((state) => state.bagsToAddToBox, 'bagsToAddToBox', [
              closedBagCan,
            ])
            .having(
              (state) => state.bagsToAddToBox,
              'bagsToAddToBox',
              isNot(contains(openBagPet)),
            ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'does not alter bagsToAddToBox when removeBagFromBoxList is called with '
      'a bag not in the list',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(bagsToAddToBox: [closedBagCan]),
      act: (cubit) {
        cubit.removeBagFromBoxList(openBagPet);
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.bagsToAddToBox,
          'bagsToAddToBox',
          [closedBagCan],
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with cleared bagsToAddToBox when clearBagsToAddToBox'
      ' is called',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        bagsToAddToBox: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.clearBagsToAddToBox();
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.bagsToAddToBox,
          'bagsToAddToBox',
          isEmpty,
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with cleared selectedBags when clearSelectedBags is called',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        selectedBags: [openBagPet, closedBagCan],
      ),
      act: (cubit) {
        cubit.clearSelectedBags();
      },
      expect: () => [
        isA<BagsState>().having(
          (state) => state.selectedBags,
          'selectedBags',
          isEmpty,
        ),
      ],
    );

    blocTest<BagsCubit, BagsState>(
      'emits state with cleared result when clearResult is called',
      build: () => bagsCubit,
      seed: () => BagsState.initial().copyWith(
        result: const Success(message: 'Test success message'),
      ),
      act: (cubit) {
        cubit.clearResult();
      },
      expect: () => [
        isA<BagsState>().having((state) => state.result, 'result', isNull),
      ],
    );
  });
}
