part of '../../ok_mobile_data.dart';

enum CollectedPackagingTypeEnum {
  glassOnly,
  plasticAndCan,
  allTypes,
  none;

  static CollectedPackagingTypeEnum fromJson(String? value) {
    if (value == null) return CollectedPackagingTypeEnum.none;

    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty || normalized == 'none') {
      return CollectedPackagingTypeEnum.none;
    }

    final items = normalized
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    final hasGlass = items.contains('glass');
    final hasPlastic = items.contains('plastic');
    final hasCan = items.contains('can');

    if (hasGlass && !hasPlastic && !hasCan && items.length == 1) {
      return CollectedPackagingTypeEnum.glassOnly;
    }

    if (!hasGlass && hasPlastic && hasCan && items.length == 2) {
      return CollectedPackagingTypeEnum.plasticAndCan;
    }

    if (hasGlass && hasPlastic && hasCan && items.length == 3) {
      return CollectedPackagingTypeEnum.allTypes;
    }

    return CollectedPackagingTypeEnum.none;
  }
}
