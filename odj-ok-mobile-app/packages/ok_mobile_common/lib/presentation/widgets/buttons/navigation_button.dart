part of '../../../ok_mobile_common.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    required this.icon,
    required this.text,
    this.onPressed,
    this.fontSize = 12,
    this.horizontalPadding,
    super.key,
  });

  final Widget icon;
  final String? text;
  final void Function()? onPressed;
  final double? fontSize;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return IconTextButton(
      icon: icon,
      onPressed: onPressed,
      text: text,
      color: AppColors.white,
      textColor: AppColors.black,
      fontSize: fontSize,
      horizontalPadding: horizontalPadding,
      border: true,
    );
  }
}
