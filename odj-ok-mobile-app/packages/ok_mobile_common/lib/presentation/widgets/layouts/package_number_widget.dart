part of '../../../ok_mobile_common.dart';

class PackageNumberWidget extends StatelessWidget {
  const PackageNumberWidget({
    required this.numberToShow,
    this.borderColor,
    this.textColor,
    this.size,
    this.margin,
    super.key,
  });

  final int numberToShow;
  final Color? borderColor;
  final Color? textColor;
  final double? size;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      width: size ?? 36,
      height: size ?? 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? AppColors.darkGrey),
      ),
      child: Text(
        numberToShow.toString(),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: numberToShow == 0
              ? AppColors.red
              : textColor ?? Theme.of(context).textTheme.titleSmall!.color,
        ),
      ),
    );
  }
}
