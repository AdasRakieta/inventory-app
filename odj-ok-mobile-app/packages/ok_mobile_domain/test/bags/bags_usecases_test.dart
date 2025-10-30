import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockBagsRepository extends Mock implements IBagsRepository {}

class MockDeviceConfigUsecases extends Mock implements DeviceConfigUsecases {}

void main() {
  late BagsUsecases bagsUsecases;
  late MockBagsRepository mockBagsRepository;
  late MockDeviceConfigUsecases mockDeviceConfigUsecases;
  late Bag commonOpenBag;
  late Bag commonClosedBag;
  late BagMetadata commonOpenBagMetadata;

  setUp(() {
    S.load(const Locale('en'));
    commonOpenBag = const Bag(
      id: '1',
      label: 'commonOpenBag',
      type: BagType.plastic,
      state: BagState.open,
      packages: [],
    );
    commonClosedBag = Bag(
      id: '2',
      label: 'commonClosedBag',
      type: BagType.plastic,
      closedTime: DateTime.now(),
      packages: const [],
    );

    commonOpenBagMetadata = BagMetadata(
      type: BagType.plastic.backendName,
      label: 'commonOpenBag',
      collectionPointId: 'collectionPointId',
    );

    mockBagsRepository = MockBagsRepository();
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

    bagsUsecases = BagsUsecases(mockBagsRepository, mockDeviceConfigUsecases);
  });

  group('BagsUsecases tests', () {
    test('addBag should add a bag and return it', () async {
      when(
        () => mockBagsRepository.addBag(commonOpenBagMetadata),
      ).thenAnswer((_) async => Right(commonOpenBag));

      final result = await bagsUsecases.addBag(commonOpenBagMetadata);

      expect(result.isRight(), true);
      expect(result, Right<Failure, Bag>(commonOpenBag));
    });

    test('fetchOpenBags should fetch and return open bags', () async {
      final openBags = [commonOpenBag];

      when(
        () => mockBagsRepository.fetchOpenBags(
          collectionPointId: 'collectionPointId',
        ),
      ).thenAnswer((_) async => Right(openBags));

      final result = await bagsUsecases.fetchOpenBags();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), openBags);
    });

    test('fetchClosedBags should fetch and return closed bags', () async {
      final closedBags = [commonClosedBag];
      when(
        () => mockBagsRepository.fetchClosedBags(
          collectionPointId: any(named: 'collectionPointId'),
        ),
      ).thenAnswer((_) async => Right(closedBags));

      final result = await bagsUsecases.fetchClosedBags();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), closedBags);
    });

    test('getBagById should return the correct bag', () async {
      when(
        () => mockBagsRepository.addBag(commonOpenBagMetadata),
      ).thenAnswer((_) async => Right(commonOpenBag));

      await bagsUsecases.addBag(commonOpenBagMetadata);

      final result = bagsUsecases.getBagById('1');
      expect(result, commonOpenBag);
    });

    test('getBagByLabel should return the correct bag', () async {
      when(
        () => mockBagsRepository.addBag(commonOpenBagMetadata),
      ).thenAnswer((_) async => Right(commonOpenBag));
      await bagsUsecases.addBag(commonOpenBagMetadata);

      final result = bagsUsecases.getBagByLabel(commonOpenBag.label);

      expect(result, commonOpenBag);
    });

    test('updateBagLabel should update the bag label', () async {
      const localBag = Bag(
        id: '1',
        label: 'Bag 1',
        type: BagType.plastic,
        state: BagState.open,
        packages: [],
      );

      final localBagMetadata = BagMetadata(
        type: BagType.plastic.backendName,
        label: 'Bag 1',
        collectionPointId: 'collectionPointId',
      );

      when(
        () => mockBagsRepository.addBag(localBagMetadata),
      ).thenAnswer((_) async => const Right(localBag));

      when(
        () => mockBagsRepository.updateBagLabel(
          any(),
          newLabel: 'New Label',
          reason: ActionReason.damagedLabel,
        ),
      ).thenAnswer((_) async => const Right(null));

      await bagsUsecases.addBag(localBagMetadata);
      final result = await bagsUsecases.updateBagLabel(
        '1',
        newLabel: 'New Label',
        reason: ActionReason.damagedLabel,
      );

      expect(result.isRight(), true);
      expect(bagsUsecases.getBagById('1')?.label, 'New Label');
    });

    test('updateBagSeal should update the bag seal', () async {
      const localBag = Bag(
        id: '1',
        label: 'Bag 1',
        type: BagType.plastic,
        packages: [],
      );

      final localBagMetadata = BagMetadata(
        type: BagType.plastic.backendName,
        label: 'Bag 1',
        collectionPointId: 'collectionPointId',
      );

      when(
        () => mockBagsRepository.addBag(localBagMetadata),
      ).thenAnswer((_) async => const Right(localBag));

      when(
        () => mockBagsRepository.closeAndSealBag(
          any(that: isA<String>()),
          seal: any(named: 'seal'),
        ),
      ).thenAnswer((_) async => const Right(null));

      when(
        () => mockBagsRepository.updateBagSeal(
          any(),
          newSeal: 'New Seal',
          reason: ActionReason.damagedSeal,
        ),
      ).thenAnswer((_) async => const Right(null));

      await bagsUsecases.addBag(localBagMetadata);
      await bagsUsecases.closeAndSealBag(localBag.id!, seal: 'Old Seal');

      final result = await bagsUsecases.updateBagSeal(
        '1',
        newSeal: 'New Seal',
        reason: ActionReason.damagedSeal,
      );

      expect(result.isRight(), true);
      expect(bagsUsecases.getBagById('1')?.seal, 'New Seal');
    });

    test('closeBag should close the bag', () async {
      const localBag = Bag(
        id: '1',
        label: 'Bag 1',
        type: BagType.plastic,
        state: BagState.open,
        packages: [],
      );

      final localBagMetadata = BagMetadata(
        type: BagType.plastic.backendName,
        label: 'Bag 1',
        collectionPointId: 'collectionPointId',
      );

      when(
        () => mockBagsRepository.addBag(localBagMetadata),
      ).thenAnswer((_) async => const Right(localBag));

      when(
        () => mockBagsRepository.closeAndSealBag(
          any(that: isA<String>()),
          seal: any(named: 'seal'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await bagsUsecases.addBag(localBagMetadata);

      final result = await bagsUsecases.closeAndSealBag('1', seal: 'sealŃ');

      expect(result.isRight(), true);
      expect(bagsUsecases.getBagById('1')?.state, BagState.closed);
    });
  });
}
