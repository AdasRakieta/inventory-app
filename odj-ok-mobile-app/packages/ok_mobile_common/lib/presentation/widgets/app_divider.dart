part of '../../../ok_mobile_common.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    this.color,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.height,
    super.key,
  });

  final Color? color;
  final EdgeInsets? padding;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            vertical: verticalPadding ?? 8,
            horizontal: horizontalPadding ?? 0,
          ),
      child: Divider(color: color ?? AppColors.grey, height: height),
    );
  }
}
