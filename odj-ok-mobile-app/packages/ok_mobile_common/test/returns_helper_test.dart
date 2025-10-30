// ignore_for_file: lines_longer_than_80_chars ignored for longer descriptions

import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';

void main() {
  group('ReturnsHelper tests', () {
    test('resolveBagType returns correct BagType', () {
      expect(ReturnsHelper.resolveBagType('Butelka PET'), BagType.plastic);
      expect(ReturnsHelper.resolveBagType('Puszka'), BagType.can);
      expect(ReturnsHelper.resolveBagType('Unknown'), null);
    });

    test(
      'aggregatePackagesFromLocalAndRemote aggregates packages correctly within one bag',
      () {
        final bag = Bag(
          id: 'bag1',
          label: '1',
          type: BagType.plastic,
          packages: [
            Package(eanCode: '123', quantity: 2),
            Package(eanCode: '456', quantity: 1),
          ],
        );

        final localReturnPackages = [
          Package(eanCode: '123', quantity: 1, bagId: 'bag1'),
          Package(eanCode: '789', quantity: 1, bagId: 'bag1'),
          Package(eanCode: '123', quantity: 2, bagId: 'bag2'), // Different bag
        ];

        final consolidated = ReturnsHelper.aggregatePackagesFromLocalAndRemote(
          bag: bag,
          localReturnPackages: localReturnPackages,
        );

        expect(consolidated.length, 3);
        expect(consolidated.firstWhere((p) => p.eanCode == '123').quantity, 3);
        expect(consolidated.firstWhere((p) => p.eanCode == '456').quantity, 1);
        expect(consolidated.firstWhere((p) => p.eanCode == '789').quantity, 1);
      },
    );

    test(
      'aggregatePackagesFromDifferentBags aggregates packages correctly from many bags',
      () {
        final localReturnPackages = [
          Package(eanCode: '123', quantity: 1, bagId: 'bag1'),
          Package(eanCode: '789', quantity: 1, bagId: 'bag1'),
          Package(eanCode: '123', quantity: 2, bagId: 'bag2'), // Different bag
        ];

        final consolidated = ReturnsHelper.aggregatePackagesFromDifferentBags(
          localReturnPackages,
        );

        expect(consolidated.length, 2);
        expect(consolidated.firstWhere((p) => p.eanCode == '123').quantity, 3);
        expect(consolidated.firstWhere((p) => p.eanCode == '789').quantity, 1);
      },
    );

    test('getNumberOfAllPackages returns correct number of packages', () {
      final bag = Bag(
        id: 'bag1',
        label: '1',
        type: BagType.plastic,
        packages: [
          Package(eanCode: '123', quantity: 2),
          Package(eanCode: '456', quantity: 1),
        ],
      );

      final openedReturn = Return(
        id: '1',
        packages: [
          Package(eanCode: '123', quantity: 1, bagId: 'bag1'),
          Package(eanCode: '789', quantity: 1, bagId: 'bag1'),
          Package(eanCode: '123', quantity: 2, bagId: 'bag2'), // Different bag
        ],
        state: ReturnState.ongoing,
      );

      final totalPackages = ReturnsHelper.getNumberOfAllPackages(
        openedReturn,
        bag,
      );

      expect(totalPackages, 5); // 3 from bag + 2 from openedReturn (bag1)
    });
  });
}
