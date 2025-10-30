part of '../../../ok_mobile_common.dart';

class ReturnStateFilters extends StatelessWidget {
  const ReturnStateFilters({
    required this.selectedReturnStates,
    required this.onPrintedFilterChanged,
    required this.onCanceledFilterChanged,
    super.key,
  });

  final List<ReturnState> selectedReturnStates;
  final ValueChanged<bool?> onPrintedFilterChanged;
  final ValueChanged<bool?> onCanceledFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Filters(
      title: S.current.filter,
      filterEntries: [
        FilterEntry(
          onChanged: onPrintedFilterChanged,
          title: S.current.correct.toUpperCase(),
          type: FilterType.returnPrinted,
          initialValue: selectedReturnStates.contains(ReturnState.printed),
        ),
        FilterEntry(
          onChanged: onCanceledFilterChanged,
          title: S.current.canceled.toUpperCase(),
          type: FilterType.returnCanceled,
          initialValue: selectedReturnStates.contains(ReturnState.canceled),
        ),
      ],
    );
  }
}
