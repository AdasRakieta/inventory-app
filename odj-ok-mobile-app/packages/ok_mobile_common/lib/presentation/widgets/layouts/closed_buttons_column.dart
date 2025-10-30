part of '../../../ok_mobile_common.dart';

class ClosedButtonsColumn extends StatelessWidget {
  const ClosedButtonsColumn({
    required this.closedBags,
    required this.selectedBag,
    required this.openedReturn,
    this.onPressed,
    super.key,
  });

  final List<Bag> closedBags;
  final void Function(Bag)? onPressed;
  final Bag? selectedBag;
  final Return? openedReturn;

  @override
  Widget build(BuildContext context) {
    return ButtonsColumn(
      buttons: List.generate(closedBags.length, (index) {
        final bag = closedBags[index];
        return ClosedBagButton(
          onPressed: () => onPressed?.call(bag),
          bag: bag,
          isSelected: bag == selectedBag,
        );
      }),
    );
  }
}
