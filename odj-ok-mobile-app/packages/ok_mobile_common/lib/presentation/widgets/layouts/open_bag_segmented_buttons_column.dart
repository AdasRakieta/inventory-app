part of '../../../ok_mobile_common.dart';

class OpenBagSegmentedButtonsColumn extends StatelessWidget {
  const OpenBagSegmentedButtonsColumn({
    required this.bags,
    required this.openedReturn,
    required this.onPressed,
    required this.selectedBagId,
    super.key,
  });

  final List<Bag> bags;
  final Return openedReturn;
  final void Function(String) onPressed;
  final String? selectedBagId;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final splices = BagsHelper.createBagSplices(bags);

        final buttonsSegments = <List<Widget>>[];
        final titles = <Widget>[];

        for (final element in splices) {
          titles.add(
            Text(
              DateFormat(
                'dd.MM.yyyy',
              ).format(element.first.openedTime ?? DateTime.now()),
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: AppColors.black),
            ),
          );

          buttonsSegments.add(
            element.map((bag) {
              return OpenBagButton(
                bag: bag,
                isSelected: bag.id == selectedBagId,
                onPressed: () => onPressed(bag.label),
              );
            }).toList(),
          );
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButtonsColumn(
                buttonsSegments: buttonsSegments,
                segmentTitles: titles,
              ),
            ],
          ),
        );
      },
    );
  }
}
