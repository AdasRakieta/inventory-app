part of '../../../ok_mobile_common.dart';

class ButtonsColumn extends StatelessWidget {
  const ButtonsColumn({
    required this.buttons,
    this.crossAxisAlignment,
    super.key,
  });

  final List<Widget> buttons;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,

      children: List.generate(
        buttons.length,
        (index) => index == buttons.length - 1
            ? buttons[index]
            : Column(children: [buttons[index], const SizedBox(height: 8)]),
      ),
    );
  }
}
