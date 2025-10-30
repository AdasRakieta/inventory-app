part of '../../ok_mobile_domain.dart';

@lazySingleton
class MasterDataUsecases {
  MasterDataUsecases(this._masterDataRepository);

  final IMasterDataRepository _masterDataRepository;
  List<Package> _packages = <Package>[];

  List<Package> get packages => _packages;

  Future<Either<Failure, Unit?>> updateMasterData() async {
    final checkedToday = await PreferencesHelper().getMasterDataCheckedToday();

    if (checkedToday) {
      final resultFromDatabase = await _masterDataRepository
          .getPackagesFromDatabase();

      return resultFromDatabase.fold(Left.new, (packages) async {
        await PreferencesHelper().setMasterDataCheckedToday();
        _packages = packages;
        return const Right(null);
      });
    }

    final dateFromDatabase = await MasterDataDatabase().readLastModifiedDate();

    final resultFromAPI = await _masterDataRepository.fetchPackages(
      dateFromDatabase,
    );

    return await resultFromAPI.fold(
      (failure) async {
        if (failure.type == FailureType.dataAlreadyUpToDate) {
          final resultFromDatabase = await _masterDataRepository
              .getPackagesFromDatabase();

          return resultFromDatabase.fold(Left.new, (packages) async {
            await PreferencesHelper().setMasterDataCheckedToday();
            _packages = packages;
            return const Right(null);
          });
        } else {
          return Left(failure);
        }
      },
      (packages) async {
        await MasterDataDatabase().insertLastModifiedDate(
          DateTime.now().toUtc().toIso8601String(),
        );
        await PreferencesHelper().setMasterDataCheckedToday();

        _packages = packages;

        return const Right(null);
      },
    );
  }

  Package? getPackageByEan(String code) {
    return _packages.firstWhereOrNull((element) => element.eanCode == code);
  }

  String? getPackageDescription(String ean) {
    final package = getPackageByEan(ean);
    return package?.description;
  }

  BagType? getPackageType(String ean) {
    final package = getPackageByEan(ean);
    return package?.type;
  }
}
