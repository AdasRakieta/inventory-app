part of '../ok_mobile_common.dart';

class BagsHelper {
  BagsHelper._();

  static Color resolveColor(BagType bagType) {
    switch (bagType) {
      case BagType.plastic:
        return AppColors.green;
      case BagType.mix:
      case BagType.can:
      case BagType.glass:
        return AppColors.black;
    }
  }

  static Color resolveBackgroundColor(BagType? bagType) {
    if (bagType == null) {
      return AppColors.white;
    }

    switch (bagType) {
      case BagType.plastic:
        return AppColors.paleGreen;
      case BagType.mix:
      case BagType.can:
        return AppColors.grey;
      case BagType.glass:
        return AppColors.babyBlue;
    }
  }

  static List<List<Bag>> createBagSplices(List<Bag> bags) => bags
      .splitAfterIndexed(
        (index, bag) =>
            index == bags.length - 1 ||
            !DatesHelper.isTheSameDay(
              bags[index].openedTime,
              bags[index + 1].openedTime,
            ),
      )
      .toList();
}
