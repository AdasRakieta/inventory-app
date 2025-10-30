part of '../../../ok_mobile_common.dart';

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({required this.buttons, super.key});

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateChildren(),
      ),
    );
  }

  List<Widget> _generateChildren() {
    final children = <Widget>[];

    for (var i = 0; i < buttons.length; i++) {
      children.add(buttons[i]);
      if (i != buttons.length - 1) {
        children.add(const SizedBox(width: 8));
      }
    }
    return children;
  }
}
