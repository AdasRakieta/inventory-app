part of '../../../../ok_mobile_data.dart';

class MasterDataDatabase {
  factory MasterDataDatabase() {
    return _instance;
  }

  MasterDataDatabase._internal();

  static const String _packageTable = 'Package';
  static const String _packageTableV2 = 'PackageV2';
  static const String _lastModifiedDateTable = 'LastModifiedDate';
  static const String _lastModifiedDateField = 'lastModifiedDate';

  String get packageTable => _packageTable;
  String get packageTableV2 => _packageTableV2;
  String get lastModifiedDateTable => _lastModifiedDateTable;
  String get lastModifiedDateField => _lastModifiedDateField;

  static final MasterDataDatabase _instance = MasterDataDatabase._internal();

  late Database _database;

  Future<void> initDatabase(String env) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, env, 'master_data.db');
    _database = await openDatabase(
      path,
      version: 4,
      onCreate: (Database db, int version) async {
        log('Creating $env database...');
        await db.execute('''
          CREATE TABLE $_packageTable(
            ean TEXT PRIMARY KEY, 
            productNameShort TEXT,
            depositAmountNet REAL,
            packageType TEXT
          )
          ''');
        await db.execute('''
          CREATE TABLE $_lastModifiedDateTable (
            lastModifiedDate TEXT
          )
          ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log(
          'Upgrading $env database from version $oldVersion to $newVersion...',
        );
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS $_packageTable');
          await db.execute('DROP TABLE IF EXISTS $_packageTableV2');
          await db.execute('''
            CREATE TABLE $_packageTable(
              ean TEXT PRIMARY KEY, 
              productNameShort TEXT,
              depositAmountNet REAL,
              packageType TEXT
            )
            ''');
        }
      },
    );
  }

  Future<void> insertLastModifiedDate(String lastModifiedDate) async {
    final batch = _database.batch()
      ..insert(_lastModifiedDateTable, {
        _lastModifiedDateField: lastModifiedDate,
      });
    final result = await batch.commit(noResult: false);
    log(result.toString());
  }

  Future<DateTime?> readLastModifiedDate() async {
    final List<Map<String, dynamic>> lastModifiedDate = await _database.query(
      _lastModifiedDateTable,
    );

    if (lastModifiedDate.isEmpty) {
      return null;
    }

    return DateTime.parse(
      lastModifiedDate.first[_lastModifiedDateField] as String,
    );
  }

  Future<void> updateDatabaseWithNewPackages(
    List<MasterdataItem> newPackages,
  ) async {
    await _database.transaction((transaction) async {
      final batch = transaction.batch();

      // Get the list of existing package EANs
      final List<Map<String, dynamic>> existingPackages = await transaction
          .query(_packageTable);
      final existingEans = existingPackages
          .map((package) => package['ean'])
          .toSet();

      // Get the list of new package EANs
      final newEans = newPackages
          .map((package) => package.toJson()['ean'])
          .toSet();

      // Delete packages that are not in the new set
      final eansToDelete = existingEans.difference(newEans);
      for (final ean in eansToDelete) {
        batch.delete(_packageTable, where: 'ean = ?', whereArgs: [ean]);
      }

      // Insert or update new packages
      for (final package in newPackages) {
        final packageMap = package.toJson();
        batch.insert(
          _packageTable,
          packageMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final result = await batch.commit(noResult: false);
      log(result.toString());
    });
  }

  Future<List<MasterdataItem>> readPackages() async {
    final List<Map<String, dynamic>> packages = await _database.query(
      _packageTable,
    );
    return packages.map(MasterdataItem.fromJson).toList();
  }

  Future<void> deleteDatabaseUtil(String env) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, env, 'master_data.db');
    await deleteDatabase(path);
  }

  Future<void> clearDatabase() async {
    await _database.transaction((transaction) async {
      final batch = transaction.batch()
        ..delete(_packageTable)
        ..delete(_lastModifiedDateTable);
      await batch.commit(noResult: true);
    });
  }

  Future<void> closeDatabase() async {
    await _database.close();
  }
}
