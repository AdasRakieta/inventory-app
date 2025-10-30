part of '../../ok_mobile_boxes.dart';

class OpenBoxButtonsColumn extends StatelessWidget {
  const OpenBoxButtonsColumn({
    required this.openBoxes,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final List<Box> openBoxes;
  final void Function(Box) onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ButtonsColumn(
      buttons: List.generate(openBoxes.length, (index) {
        final box = openBoxes[index];
        return OpenBoxButton(
          onPressed: () => onPressed(box),
          box: box,
          icon: icon,
        );
      }),
    );
  }
}
