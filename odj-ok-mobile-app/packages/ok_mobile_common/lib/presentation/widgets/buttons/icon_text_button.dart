part of '../../../ok_mobile_common.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    required this.icon,
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
  final Widget icon;
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
        child: Row(
          children: [
            SizedBox(height: 16, child: icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text ?? '',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: enabled ? textColor : AppColors.lightBlack,
                  fontSize: fontSize,
                ),
              ),
            ),
            if (trailingIcon != null) SizedBox(height: 16, child: trailingIcon),
          ],
        ),
      ),
    );
  }
}
