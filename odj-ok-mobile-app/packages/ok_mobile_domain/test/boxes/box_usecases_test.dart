import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockBoxRepository extends Mock implements IBoxRepository {}

class MockDeviceConfigUsecases extends Mock implements DeviceConfigUsecases {}

void main() {
  late BoxUsecases boxUsecases;
  late MockBoxRepository mockBoxRepository;
  late MockDeviceConfigUsecases mockDeviceConfigUsecases;
  late Box commonOpenBox;
  late Box commonClosedBox;

  setUpAll(() {
    S.load(const Locale('en'));
    commonOpenBox = Box(
      id: '1',
      label: 'Box 1',
      isOpen: true,
      dateOpened: DateTime.now(),
      bags: [],
    );

    commonClosedBox = Box(
      id: '1',
      label: 'Box 1',
      isOpen: true,
      dateOpened: DateTime.now().subtract(const Duration(days: 1)),
      dateClosed: DateTime.now(),
      bags: [],
    );

    mockDeviceConfigUsecases = MockDeviceConfigUsecases();
    when(() => mockDeviceConfigUsecases.collectionPointData).thenReturn(
      const CollectionPointData(
        id: 'collectionPointId',
        code: 'collectionPointCode',
        name: 'collectionPointName',
        segregatesItems: true,
        collectedPackagingType: CollectedPackagingTypeEnum.allTypes,
      ),
    );

    mockBoxRepository = MockBoxRepository();
    boxUsecases = BoxUsecases(mockBoxRepository, mockDeviceConfigUsecases);
  });

  group('BoxUsecases tests', () {
    test('openNewBox should open a new box and return it', () async {
      when(
        () => mockBoxRepository.openNewBox(
          boxCode: 'boxCode',
          collectionPointId: 'collectionPointId',
        ),
      ).thenAnswer((_) async => Right(commonOpenBox));

      final result = await boxUsecases.openNewBox(boxCode: 'boxCode');

      expect(result.isRight(), true);
      expect(result, Right<Failure, Box>(commonOpenBox));
    });

    test('fetchOpenBoxes should fetch and return open boxes', () async {
      final openBoxes = [commonOpenBox];

      when(
        () => mockBoxRepository.fetchOpenBoxes(
          collectionPointId: 'collectionPointId',
        ),
      ).thenAnswer((_) async => Right(openBoxes));

      final result = await boxUsecases.fetchOpenBoxes();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), openBoxes);
    });

    test('fetchClosedBoxes should fetch and return closed boxes', () async {
      final closedBoxes = [commonClosedBox];
      when(
        () => mockBoxRepository.fetchClosedBoxes(
          collectionPointId: 'collectionPointId',
        ),
      ).thenAnswer((_) async => Right(closedBoxes));

      final result = await boxUsecases.fetchClosedBoxes();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), closedBoxes);
    });

    test('addBagsToBox should add bags to the box', () async {
      when(
        () => mockBoxRepository.addBagsToBox(boxId: '1', bagCodes: ['bagCode']),
      ).thenAnswer((_) async => const Right(null));

      final result = await boxUsecases.addBagsToBox(
        boxId: '1',
        bagCodes: ['bagCode'],
      );

      expect(result.isRight(), true);
    });

    test('removeBagFromBox should remove a bag from the box', () async {
      when(
        () => mockBoxRepository.removeBagFromBox(boxId: '1', bagId: 'bagId'),
      ).thenAnswer((_) async => const Right(null));

      final result = await boxUsecases.removeBagFromBox(
        boxId: '1',
        bagId: 'bagId',
      );

      expect(result.isRight(), true);
    });

    test('closeBoxes should close the boxes', () async {
      when(
        () => mockBoxRepository.closeBoxes(['1']),
      ).thenAnswer((_) async => const Right(null));

      final result = await boxUsecases.closeBoxes(['1']);

      expect(result.isRight(), true);
    });

    test('updateBoxLabel should update the box label', () async {
      when(
        () => mockBoxRepository.updateBoxLabel(
          '1',
          newLabel: 'New Label',
          reason: ActionReason.damagedLabel,
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await boxUsecases.updateBoxLabel(
        '1',
        newLabel: 'New Label',
        reason: ActionReason.damagedLabel,
      );

      expect(result.isRight(), true);
    });
  });
}
