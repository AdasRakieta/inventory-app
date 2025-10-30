part of '../../ok_mobile_bags.dart';

class OpenButtonsColumn extends StatelessWidget {
  const OpenButtonsColumn({
    required this.openBags,
    required this.openedReturn,
    required this.onPressed,
    super.key,
  });

  final List<Bag> openBags;
  final Return openedReturn;
  final void Function(Bag) onPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonsColumn(
      buttons: List.generate(openBags.length, (index) {
        final bag = openBags[index];
        return OpenBagButton(
          onPressed: () => onPressed(bag),
          bag: bag,
          isSelected: context.read<BagsCubit>().state.selectedBag == bag,
        );
      }),
    );
  }
}
