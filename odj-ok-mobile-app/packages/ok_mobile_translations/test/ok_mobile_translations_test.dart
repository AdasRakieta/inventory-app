import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Test localization cubit', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late LocalizationCubit localizationCubit;

    SharedPreferences.setMockInitialValues({CacheKeys.preferedLanguage: 'de'});

    setUp(() {
      localizationCubit = LocalizationCubit(
        LocalizationUsecases(LocalizationRepository()),
      );
    });

    test('Initial state with saved language', () {
      emitsInOrder([
        const LocalizationState(currentLocale: Locale('en')),
        const LocalizationState(currentLocale: Locale('de')),
      ]);
    });

    blocTest<LocalizationCubit, LocalizationState>(
      'Test changeLocale method',
      build: () => localizationCubit,
      act: (cubit) => cubit.changeLocale(const Locale('pl')),
      expect: () => [const LocalizationState(currentLocale: Locale('pl'))],
    );
  });
}
