import 'package:flutter_test/flutter_test.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize sqflite for test.
void sqfliteTestInit() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory
  databaseFactory = databaseFactoryFfi;
}

void main() {
  late String path;
  const env = 'testing';

  setUp(() async {
    sqfliteTestInit();
    final databasesPath = await getDatabasesPath();
    path = join(databasesPath, env, 'master_data.db');
    await MasterDataDatabase().initDatabase(env);
  });

  tearDown(() {
    deleteDatabase(path);
  });

  group('MasterDataDatabase tests', () {
    test('MasterDataDatabase initializes database correctly', () async {
      final db = await openDatabase(path);

      await db.insert(MasterDataDatabase().lastModifiedDateTable, {
        MasterDataDatabase().lastModifiedDateField: '2021-09-01T00:00:00.000Z',
      });

      final result = await db.query(MasterDataDatabase().lastModifiedDateTable);

      expect(result.length, 1);
      expect(result.first, {'lastModifiedDate': '2021-09-01T00:00:00.000Z'});
    });

    test('MasterDataDatabase handles lastModifiedDate correctly', () async {
      const lastModifiedDate = '2021-09-01T00:00:00.000Z';

      await MasterDataDatabase().insertLastModifiedDate(lastModifiedDate);

      final result = await MasterDataDatabase().readLastModifiedDate();

      expect(result?.toIso8601String(), lastModifiedDate);
    });

    test(
      'MasterDataDatabase updates database with new packages correctly',
      () async {
        final initialPackages = [
          MasterdataItem(
            ean: '123',
            productNameShort: 'Package 1',
            depositAmountNet: 0.5,
            packageType: PackageType.can,
          ),
          MasterdataItem(
            ean: '456',
            productNameShort: 'Package 2',
            depositAmountNet: 0.5,
            packageType: PackageType.plastic,
          ),
          MasterdataItem(
            ean: '789',
            productNameShort: 'Package 3',
            depositAmountNet: 0.5,
            packageType: PackageType.glass,
          ),
        ];

        await MasterDataDatabase().updateDatabaseWithNewPackages(
          initialPackages,
        );

        var packages = await MasterDataDatabase().readPackages();

        expect(packages.length, 3);

        final newPackages = [
          MasterdataItem(
            ean: '123',
            productNameShort: 'Updated Package 1',
            depositAmountNet: 0.5,
            packageType: PackageType.plastic,
          ),
          MasterdataItem(
            ean: '789',
            productNameShort: 'Package 3',
            depositAmountNet: 0.5,
            packageType: PackageType.glass,
          ),
          MasterdataItem(
            ean: '1011',
            productNameShort: 'Package ',
            depositAmountNet: 0.5,
            packageType: PackageType.can,
          ),
        ];

        await MasterDataDatabase().updateDatabaseWithNewPackages(newPackages);

        packages = await MasterDataDatabase().readPackages();

        expect(packages.length, 3);
        expect(packages.any((p) => p.ean == '456'), false);
        expect(
          packages.any(
            (p) => p.ean == '123' && p.productNameShort == 'Updated Package 1',
          ),
          true,
        );
        expect(
          packages.any(
            (p) => p.ean == '789' && p.productNameShort == 'Package 3',
          ),
          true,
        );
      },
    );
  });
}
