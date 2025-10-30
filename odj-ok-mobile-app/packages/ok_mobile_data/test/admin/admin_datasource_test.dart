import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AdminDatasource adminDatasource;

  setUp(() {
    adminDatasource = AdminDatasource();
  });

  group('AdminDatasource', () {
    test('getPrinter returns null when no printer is saved', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await adminDatasource.getPrinter();

      expect(result, isNull);
    });
    test('getPrinter returns saved printer MAC address', () async {
      SharedPreferences.setMockInitialValues({
        CacheKeys.savedPrinterMacAddress: '00:11:22:33:44:55',
      });

      final result = await adminDatasource.getPrinter();

      expect(result, '00:11:22:33:44:55');
    });

    test('setPrinter saves printer MAC address', () async {
      SharedPreferences.setMockInitialValues({});

      await adminDatasource.setPrinter('00:11:22:33:44:55');

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(CacheKeys.savedPrinterMacAddress),
        '00:11:22:33:44:55',
      );
    });

    test('removePrinter removes saved printer MAC address', () async {
      SharedPreferences.setMockInitialValues({
        CacheKeys.savedPrinterMacAddress: '00:11:22:33:44:55',
      });

      await adminDatasource.removePrinter();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(CacheKeys.savedPrinterMacAddress), isNull);
    });

    test(
      'removePrinter does nothing if printer MAC address is not saved',
      () async {
        SharedPreferences.setMockInitialValues({});

        await adminDatasource.removePrinter();

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getString(CacheKeys.savedPrinterMacAddress), isNull);
      },
    );

    test('comprehensive AdminDatasource test', () async {
      SharedPreferences.setMockInitialValues({});

      await adminDatasource.setPrinter('00:11:22:33:44:55');
      final printer = await adminDatasource.getPrinter();

      expect(printer, '00:11:22:33:44:55');

      await adminDatasource.removePrinter();

      expect(await adminDatasource.getPrinter(), isNull);
    });
  });
}
