part of '../ok_mobile_common.dart';

class ReturnsHelper {
  const ReturnsHelper._();

  static Widget resolveLeadingIcon(ReturnState? state) {
    switch (state) {
      case ReturnState.canceled:
        return Assets.icons.printerCrossed.image(package: 'ok_mobile_common');
      case ReturnState.ongoing:
        return Assets.icons.printer.image(
          package: 'ok_mobile_common',
          color: AppColors.yellow,
        );
      case ReturnState.unfinished:
        return Assets.icons.printer.image(
          package: 'ok_mobile_common',
          color: AppColors.yellow,
        );
      case ReturnState.printed:
      case null:
        return Assets.icons.scroll.image(
          package: 'ok_mobile_common',
          color: AppColors.lightGreen,
        );
    }
  }

  static String resolveReturnStateText(ReturnState state) {
    switch (state) {
      case ReturnState.canceled:
        return S.current.cancelled_print;
      case ReturnState.printed:
        return S.current.correct_print;
      case ReturnState.unfinished:
        return S.current.before_print;
      case ReturnState.ongoing:
        return S.current.before_print;
    }
  }

  static BagType? resolveBagType(String type) {
    switch (type) {
      case 'Butelka PET':
        return BagType.plastic;
      case 'Puszka':
        return BagType.can;
      default:
        return null;
    }
  }

  static BagType? resolveBagTypeV2(PackageType? type) {
    switch (type) {
      case PackageType.plastic:
        return BagType.plastic;
      case PackageType.can:
        return BagType.can;
      case PackageType.glass:
        return BagType.glass;
      case PackageType.box:
      case PackageType.bottleInBox:
      case PackageType.carton:
      case PackageType.pouch:
      case PackageType.jar:
      case PackageType.tube:
      case PackageType.invalid:
      case null:
        return null;
    }
  }

  static List<Package> aggregatePackagesFromDifferentBags(
    List<Package> packages,
  ) {
    final aggregatedList = <Package>[];

    for (final package in packages) {
      final existingPackage = aggregatedList.firstWhereOrNull(
        (p) => p.eanCode == package.eanCode,
      );

      if (existingPackage != null) {
        existingPackage.increaseQuantity(amount: package.quantity);
      } else {
        aggregatedList.add(package.copy());
      }
    }

    return aggregatedList;
  }

  static List<Package> aggregatePackagesFromLocalAndRemote({
    required Bag? bag,
    required List<Package> localReturnPackages,
  }) {
    final bagPackages = bag?.packages ?? [];
    final aggregatedPackages = <Package>[];

    final aggregationMap = <String, Package>{};

    for (final package in bagPackages) {
      if (aggregationMap.containsKey(package.eanCode)) {
        aggregationMap[package.eanCode]!.increaseQuantity(
          amount: package.quantity,
        );
      } else {
        aggregationMap[package.eanCode] = package.copy();
      }
    }

    for (final localPackage in localReturnPackages) {
      if (localPackage.bagId != bag?.id) {
        continue;
      }
      if (aggregationMap.containsKey(localPackage.eanCode)) {
        aggregationMap[localPackage.eanCode]!.increaseQuantity(
          amount: localPackage.quantity,
        );
      } else {
        aggregationMap[localPackage.eanCode] = localPackage.copy();
      }
    }

    for (final package in aggregationMap.values) {
      aggregatedPackages.add(package);
    }

    return aggregatedPackages;
  }

  static int getNumberOfAllPackages(Return? openedReturn, Bag bag) {
    if (openedReturn == null) {
      return bag.numberOfPackages;
    }
    return openedReturn.packages
            .where((returnItem) => returnItem.bagId == bag.id)
            .fold(0, (sum, returnItem) => sum + returnItem.quantity) +
        bag.numberOfPackages;
  }

  static int getNumberOfAllPPackagesInReturn(Return? openedReturn) {
    if (openedReturn == null) {
      return 0;
    }
    return openedReturn.packages.fold(
      0,
      (sum, returnItem) => sum + returnItem.quantity,
    );
  }

  static String formatDepositValue(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
}
