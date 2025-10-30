part of '../../ok_mobile_boxes.dart';

class ClosedBoxButtonsColumn extends StatelessWidget {
  const ClosedBoxButtonsColumn({
    required this.closedBoxes,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final List<Box> closedBoxes;
  final void Function(Box) onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ButtonsColumn(
      buttons: List.generate(closedBoxes.length, (index) {
        final box = closedBoxes[index];
        return ClosedBoxButton(
          onPressed: () => onPressed(box),
          box: box,
          icon: icon,
        );
      }),
    );
  }
}
