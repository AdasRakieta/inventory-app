import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PreferencesHelper preferencesHelper;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    preferencesHelper = PreferencesHelper();
  });

  group('PreferencesHelper', () {
    test(
      'getMasterDataCheckedToday returns true if lastModifiedDate is today',
      () async {
        final today = DateTime.now().toIso8601String();

        SharedPreferences.setMockInitialValues({'lastModifiedDate': today});
        final result = await preferencesHelper.getMasterDataCheckedToday();

        expect(result, isTrue);
      },
    );

    test('getMasterDataCheckedToday returns false if lastModifiedDate '
        'is not today', () async {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();

      SharedPreferences.setMockInitialValues({'lastModifiedDate': yesterday});
      final result = await preferencesHelper.getMasterDataCheckedToday();

      expect(result, isFalse);
    });

    test(
      'getMasterDataCheckedToday returns false if lastModifiedDate is null',
      () async {
        SharedPreferences.setMockInitialValues({});
        final result = await preferencesHelper.getMasterDataCheckedToday();

        expect(result, isFalse);
      },
    );

    test('setMasterDataCheckedToday sets lastModifiedDate to today', () async {
      SharedPreferences.setMockInitialValues({});

      await preferencesHelper.setMasterDataCheckedToday();
    });

    test('clearMasterDataCheckedToday removes lastModifiedDate', () async {
      SharedPreferences.setMockInitialValues({});
      await preferencesHelper.setMasterDataCheckedToday();

      var result = await preferencesHelper.getMasterDataCheckedToday();

      expect(result, isTrue);

      await preferencesHelper.clearMasterDataPrefs();

      result = await preferencesHelper.getMasterDataCheckedToday();

      expect(result, isFalse);
    });
  });
}
