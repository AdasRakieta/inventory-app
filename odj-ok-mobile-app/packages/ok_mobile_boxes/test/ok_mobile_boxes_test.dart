import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockBoxUsecases extends Mock implements BoxUsecases {}

void main() {
  group('BoxCubit tests', () {
    late BoxCubit boxCubit;
    late MockBoxUsecases mockBoxUsecases;

    late Failure failure;
    late Box testBox1;
    late Box testBox2;
    late Box closedBox;
    late Bag bag;
    late Bag updatedBag;

    setUpAll(() async {
      await S.load(const Locale('en'));
    });

    setUp(() async {
      bag = const Bag(
        id: 'id 1',
        label: 'label 1',
        type: BagType.mix,
        packages: [],
      );
      updatedBag = bag.copyWith(label: 'updated');
      testBox1 = Box(
        id: 'id',
        label: 'label',
        bags: [bag],
        dateOpened: DateTime.now(),
      );

      testBox2 = Box(
        id: 'id 2',
        label: 'label 2',
        bags: [bag],
        dateOpened: DateTime.now(),
      );

      closedBox = Box(
        id: 'id',
        label: 'label',
        bags: [],
        dateOpened: DateTime.now().subtract(const Duration(days: 1)),
        dateClosed: DateTime.now(),
      );

      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
      );

      mockBoxUsecases = MockBoxUsecases();
      boxCubit = BoxCubit(mockBoxUsecases);
    });

    blocTest<BoxCubit, BoxState>(
      'emits box and Success when selectBox is called',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(openBoxes: [testBox1]);
      },
      act: (cubit) {
        cubit.selectBox(testBox1);
      },
      expect: () => [
        isA<BoxState>()
            .having((state) => state.selectedBox, 'selectedBox', testBox1)
            .having(
              (state) => state.result,
              'result',
              isA<Success>().having(
                (success) => success.message,
                'message',
                S.current.box_correctly_opened,
              ),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits box with no success message when selectBox is called with '
      'showSnackBar set to  false',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(openBoxes: [testBox1]);
      },
      act: (cubit) {
        cubit.selectBox(testBox1, showSnackBar: false);
      },
      expect: () => [
        isA<BoxState>()
            .having((state) => state.selectedBox, 'selectedBox', testBox1)
            .having((state) => state.result, 'result', isNull),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits box and Success when selectBoxByLabel is called '
      'with a valid label',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(openBoxes: [testBox1]);
      },
      act: (cubit) {
        cubit.selectBoxByLabel(testBox1.label);
      },
      expect: () => [
        isA<BoxState>()
            .having((state) => state.selectedBox, 'selectedBox', testBox1)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.box_correctly_opened),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits Failure when selectBoxByLabel is called with an invalid label',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(openBoxes: [testBox1]);
      },
      act: (cubit) {
        cubit.selectBoxByLabel('invalid_label');
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.result,
          'result',
          Failure(
            message: S.current.box_not_found,
            severity: FailureSeverity.warning,
            type: FailureType.general,
          ),
        ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'returns box and emits nothing when checkIfOpenBoxExists is called '
      'with a valid label',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(openBoxes: [testBox1]);
      },
      act: (cubit) {
        final result = cubit.checkIfOpenBoxExists(testBox1.label);
        expect(result, testBox1);
      },
      expect: () => <BoxState>[],
    );

    blocTest<BoxCubit, BoxState>(
      'emits failure when checkIfOpenBoxExists is called '
      'with a valid label but chosen box has empty bags',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(
          openBoxes: [testBox1.copyWith(bags: [])],
        );
      },
      act: (cubit) {
        final result = cubit.checkIfOpenBoxExists(testBox1.label);
        expect(result, isNull);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.result,
          'result',
          Failure(
            message: S.current.box_not_found,
            severity: FailureSeverity.warning,
            type: FailureType.boxNotFound,
          ),
        ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'returns null and emits Failure when checkIfOpenBoxExists is called '
      'with an invalid label',
      build: () => boxCubit,
      seed: () {
        return BoxState.initial().copyWith(openBoxes: [testBox1]);
      },
      act: (cubit) {
        final result = cubit.checkIfOpenBoxExists('invalid_label');
        expect(result, null);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.result,
          'result',
          Failure(
            message: S.current.box_not_found,
            severity: FailureSeverity.warning,
            type: FailureType.boxNotFound,
          ),
        ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [loading, loaded +  box + success] when openNewBox is successful',
      build: () {
        when(
          () => mockBoxUsecases.openNewBox(boxCode: testBox1.label),
        ).thenAnswer((_) async => Right(testBox1));
        return boxCubit;
      },
      act: (cubit) async {
        await cubit.openNewBox(testBox1.label);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.selectedBox, 'selectedBox', testBox1)
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.new_box_opened_correctly),
            )
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [BoxState.loading, BoxState.loaded and failure] when '
      'openNewBox fails',
      build: () {
        when(
          () => mockBoxUsecases.openNewBox(boxCode: testBox1.label),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      act: (cubit) async {
        await cubit.openNewBox(testBox1.label);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [BoxState.loading, BoxState.loaded, boxes] when fetchOpenBoxes'
      ' is successful',
      build: () {
        when(
          () => mockBoxUsecases.fetchOpenBoxes(),
        ).thenAnswer((_) async => Right([testBox1, testBox2]));
        return boxCubit;
      },
      act: (cubit) async {
        await cubit.fetchOpenBoxes();
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.openBoxes, 'openBoxes', [
              testBox1,
              testBox2,
            ])
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [BoxState.loading, BoxState.loaded, failure] when fetchOpenBoxes '
      'fails',
      build: () {
        when(
          () => mockBoxUsecases.fetchOpenBoxes(),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      act: (cubit) async {
        await cubit.fetchOpenBoxes();
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [BoxState.loading, BoxState.loaded, boxes] when fetchClosedBoxes '
      'is successful',
      build: () {
        when(
          () => mockBoxUsecases.fetchClosedBoxes(),
        ).thenAnswer((_) async => Right([closedBox, closedBox]));
        return boxCubit;
      },
      act: (cubit) async {
        await cubit.fetchClosedBoxes();
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.closedBoxes, 'closedBoxes', [
              closedBox,
              closedBox,
            ])
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [BoxState.loading, BoxState.loaded, failure] when '
      'fetchClosedBoxes fails',
      build: () {
        when(
          () => mockBoxUsecases.fetchClosedBoxes(),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      act: (cubit) async => cubit.fetchClosedBoxes(),
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    test(
      'returns list of bag IDs when getSelectedBoxBagIDs is called and a box '
      'with not empty bags is selected',
      () {
        final state = BoxState.initial().copyWith(selectedBox: testBox1);
        boxCubit.emit(state);

        final result = boxCubit.getSelectedBoxBagIds();
        expect(result, [bag.id]);
      },
    );

    test('returns empty list when getSelectedBoxBagIDs is called and no box '
        'is selected', () {
      final state = BoxState.initial();
      boxCubit.emit(state);

      final result = boxCubit.getSelectedBoxBagIds();
      expect(result, isEmpty);
    });

    test(
      'returns empty list when getSelectedBoxBagIDs is called and a box with '
      'empty bags is selected',
      () {
        final state = BoxState.initial().copyWith(
          selectedBox: testBox1.copyWith(bags: []),
        );
        boxCubit.emit(state);

        final result = boxCubit.getSelectedBoxBagIds();
        expect(result, isEmpty);
      },
    );

    blocTest<BoxCubit, BoxState>(
      'emits [updatedBag] when updateBagsInfo is called',
      build: () {
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) {
        cubit.updateBagsInfo([updatedBag]);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.selectedBox.bags,
          'selectedBox.bags',
          contains(updatedBag),
        ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [loading, loaded + success + selected box bags containing added '
      'bag] when addBagsToBox is successful',
      build: () {
        when(() {
          return mockBoxUsecases.addBagsToBox(
            boxId: testBox1.id,
            bagCodes: [bag.id!],
          );
        }).thenAnswer(
          (_) async => Right(Success(message: S.current.bag_was_added_to_box)),
        );
        return boxCubit;
      },
      seed: () =>
          BoxState.initial().copyWith(selectedBox: testBox1.copyWith(bags: [])),
      act: (cubit) async {
        final result = await cubit.addBagsToBox(bags: [bag]);
        expect(result, isTrue);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.bag_was_added_to_box),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.selectedBox.bags,
              'selectedBox.bags',
              contains(bag),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [BoxState.loading, BoxState.loaded + failure] when addBagsToBox'
      ' fails',
      build: () {
        when(
          () => mockBoxUsecases.addBagsToBox(
            boxId: testBox1.id,
            bagCodes: [bag.id!],
          ),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) async {
        final result = await cubit.addBagsToBox(bags: [bag]);
        expect(result, isFalse);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits loading, loaded + selected box does not contain'
      ' selected bag when removeBagFromBox is successful',
      build: () {
        when(
          () => mockBoxUsecases.removeBagFromBox(
            boxId: testBox1.id,
            bagId: bag.id!,
          ),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.bag_was_removed_from_box)),
        );
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) async {
        await cubit.removeBagFromBox(bag);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.bag_was_removed_from_box),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.selectedBox.bags,
              'selectedBox.bags',
              isNot(contains(bag)),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits loading, loaded + failure + selected box still contains selected'
      ' bag when removeBagFromBox fails',
      build: () {
        when(
          () => mockBoxUsecases.removeBagFromBox(
            boxId: testBox1.id,
            bagId: bag.id!,
          ),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) async {
        await cubit.removeBagFromBox(bag);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.selectedBox.bags,
              'selectedBox.bags',
              contains(bag),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits loading, loaded + open boxes not containing selected box + '
      'closed boxes containing selected box when closeBoxes is successful with '
      'one box selected',
      build: () {
        when(() => mockBoxUsecases.closeBoxes([testBox1.id])).thenAnswer(
          (_) async => Right(Success(message: S.current.box_was_closed)),
        );
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(openBoxes: [testBox1, testBox2]),
      act: (cubit) async {
        final result = await cubit.closeBoxes([testBox1.id]);
        expect(result, isTrue);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.box_was_closed),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.openBoxes,
              'openBoxes',
              isNot(contains(testBox1)),
            )
            .having(
              (state) => state.closedBoxes,
              'closedBoxes',
              contains(testBox1),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits loading, loaded + open boxes not containing selected box + '
      'closed boxes containing selected box when closeBoxes is successful with '
      'multiple boxes selected',
      build: () {
        when(
          () => mockBoxUsecases.closeBoxes([testBox1.id, testBox2.id]),
        ).thenAnswer(
          (_) async => Right(Success(message: S.current.all_boxes_closed)),
        );
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(openBoxes: [testBox1, testBox2]),
      act: (cubit) async {
        final result = await cubit.closeBoxes([testBox1.id, testBox2.id]);
        expect(result, isTrue);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.all_boxes_closed),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.openBoxes,
              'openBoxes',
              isNot(contains(testBox1)),
            )
            .having(
              (state) => state.openBoxes,
              'openBoxes',
              isNot(contains(testBox2)),
            )
            .having(
              (state) => state.closedBoxes,
              'closedBoxes',
              contains(testBox1),
            )
            .having(
              (state) => state.closedBoxes,
              'closedBoxes',
              contains(testBox2),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits loading, loaded + failure, open boxes containing selected box and '
      'closed boxes not containing selected box when closeBoxes fails',
      build: () {
        when(
          () => mockBoxUsecases.closeBoxes([testBox1.id]),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(openBoxes: [testBox1]),
      act: (cubit) async {
        final result = await cubit.closeBoxes([testBox1.id]);
        expect(result, isFalse);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.openBoxes, 'openBoxes', contains(testBox1))
            .having(
              (state) => state.closedBoxes,
              'closedBoxes',
              isNot(contains(testBox1)),
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits state with Box.empty when clearSelectedBox is called',
      build: () => boxCubit,
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) {
        cubit.clearSelectedBox();
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.selectedBox,
          'selectedBox',
          isNot(testBox1),
        ),
      ],
    );
    blocTest<BoxCubit, BoxState>(
      'emits state with null result when clearResult is called',
      build: () => boxCubit,
      seed: () =>
          BoxState.initial().copyWith(result: const Success(message: 'Test')),
      act: (cubit) {
        cubit.clearResult();
      },
      expect: () => [
        isA<BoxState>().having((state) => state.result, 'result', null),
      ],
    );
    blocTest<BoxCubit, BoxState>(
      'emits [loading, loaded + success + new selected box label] when '
      'updateBoxLabel is successful',
      build: () {
        when(
          () => mockBoxUsecases.updateBoxLabel(
            testBox1.id,
            newLabel: 'new_label',
            reason: ActionReason.tornBox,
          ),
        ).thenAnswer(
          (_) async =>
              Right(Success(message: S.current.label_has_been_changed)),
        );
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) async {
        final result = await cubit.updateBoxLabel(
          testBox1.id,
          newLabel: 'new_label',
          reason: ActionReason.tornBox,
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.label_has_been_changed),
            )
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.selectedBox.label,
              'selectedBox.label',
              'new_label',
            ),
      ],
    );

    blocTest<BoxCubit, BoxState>(
      'emits [loading, loaded + failure] when updateBoxLabel fails',
      build: () {
        when(
          () => mockBoxUsecases.updateBoxLabel(
            testBox1.id,
            newLabel: 'new_label',
            reason: ActionReason.tornBox,
          ),
        ).thenAnswer((_) async => Left(failure));
        return boxCubit;
      },
      seed: () => BoxState.initial().copyWith(selectedBox: testBox1),
      act: (cubit) async {
        final result = await cubit.updateBoxLabel(
          testBox1.id,
          newLabel: 'new_label',
          reason: ActionReason.tornBox,
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<BoxState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<BoxState>()
            .having((state) => state.result, 'result', failure)
            .having((state) => state.state, 'state', GeneralState.loaded),
      ],
    );
  });
}
