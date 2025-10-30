import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';

void main() {
  group('BagsHelper', () {
    test('resolveColor returns AppColors.green for BagType.pet', () {
      final color = BagsHelper.resolveColor(BagType.plastic);
      expect(color, AppColors.green);
    });

    test('resolveColor returns AppColors.black for BagType.mix', () {
      final color = BagsHelper.resolveColor(BagType.mix);
      expect(color, AppColors.black);
    });

    test('resolveColor returns AppColors.black for BagType.can', () {
      final color = BagsHelper.resolveColor(BagType.can);
      expect(color, AppColors.black);
    });
  });
}
