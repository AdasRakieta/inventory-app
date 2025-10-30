part of '../../../ok_mobile_common.dart';

class PackageTypeFilters extends StatelessWidget {
  const PackageTypeFilters({
    required this.selectedBagTypes,
    required this.onPetFilterChanged,
    required this.onCanFilterChanged,
    super.key,
  });

  final List<BagType> selectedBagTypes;
  final ValueChanged<bool?> onPetFilterChanged;
  final ValueChanged<bool?> onCanFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Filters(
      title: S.current.filter,
      filterEntries: [
        FilterEntry(
          onChanged: onPetFilterChanged,
          title: S.current.plastic.toUpperCase(),
          type: FilterType.bagPET,
        ),
        FilterEntry(
          onChanged: onCanFilterChanged,
          title: S.current.can.toUpperCase(),
          type: FilterType.bagCan,
        ),
      ],
    );
  }
}
