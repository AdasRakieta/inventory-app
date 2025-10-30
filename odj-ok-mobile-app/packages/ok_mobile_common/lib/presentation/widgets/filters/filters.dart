part of '../../../ok_mobile_common.dart';

enum FilterType {
  bagPET,
  bagCan,
  bagClosed,
  bagOpen,
  boxClosed,
  boxOpen,
  returnPrinted,
  returnCanceled,
}

class FilterEntry {
  FilterEntry({
    required this.title,
    required this.onChanged,
    required this.type,
    this.initialValue = false,
  });

  final String title;
  final ValueChanged<bool?> onChanged;
  final bool initialValue;
  final FilterType type;
}

class Filters extends StatefulWidget {
  const Filters({required this.filterEntries, required this.title, super.key});

  final String title;
  final List<FilterEntry> filterEntries;

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(right: 20),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [...mapEntries().expand((element) => element)],
            ),
          ),
        ),
      ],
    );
  }

  List<List<Widget>> mapEntries() {
    return widget.filterEntries.map((entry) {
      switch (entry.type) {
        case FilterType.bagPET:
          return [
            const SizedBox(width: 8),
            FiltersCheckbox.pet(
              onChanged: entry.onChanged,
              text: entry.title,
              value: entry.initialValue,
            ),
          ];
        case FilterType.bagCan:
          return [
            const SizedBox(width: 8),
            FiltersCheckbox.can(
              onChanged: entry.onChanged,
              text: entry.title,
              value: entry.initialValue,
            ),
          ];
        case FilterType.returnPrinted:
          return [
            const SizedBox(width: 8),
            FiltersCheckbox.correct(
              onChanged: entry.onChanged,
              text: entry.title,
              value: entry.initialValue,
            ),
          ];
        case FilterType.returnCanceled:
          return [
            const SizedBox(width: 8),
            FiltersCheckbox.canceled(
              onChanged: entry.onChanged,
              text: entry.title,
              value: entry.initialValue,
            ),
          ];
        case FilterType.bagOpen:
        case FilterType.boxOpen:
        case FilterType.bagClosed:
        case FilterType.boxClosed:
          return [
            const SizedBox(width: 8),
            FiltersCheckbox.generic(
              onChanged: entry.onChanged,
              text: entry.title,
              value: entry.initialValue,
            ),
          ];
      }
    }).toList();
  }
}
