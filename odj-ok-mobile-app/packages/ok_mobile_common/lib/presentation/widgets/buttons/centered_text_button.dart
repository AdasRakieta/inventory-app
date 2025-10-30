part of '../../../ok_mobile_common.dart';

class CenteredTextButton extends StatelessWidget {
  const CenteredTextButton({
    required this.onPressed,
    required this.text,
    this.trailingIcon,
    this.border = false,
    this.color,
    this.textColor = AppColors.white,
    this.fontSize = 12,
    this.enabled = true,
    this.horizontalPadding,
    super.key,
  });

  final bool border;
  final Color? color;
  final String? text;
  final void Function()? onPressed;
  final Color? textColor;
  final double? fontSize;
  final bool enabled;
  final Widget? trailingIcon;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled
        ? color ?? Theme.of(context).primaryColor
        : AppColors.darkGrey;

    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shape: border
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.darkGrey),
                )
              : null,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 16),
        ),
        child: Center(
          child: Text(
            text ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: enabled ? textColor : AppColors.lightBlack,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
