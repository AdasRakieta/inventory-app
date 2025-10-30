part of '../../../ok_mobile_common.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
    required this.onPressed,
    this.border,
    this.color,
    this.leadingIcon,
    this.mainTitle,
    this.secondLowerTitle,
    this.textColor,
    this.fontSize,
    this.upperTitle,
    this.upperTitleColor,
    this.secondUpperTitle,
    this.trailingIcon,
    this.buttonHeight,
    this.titleWidget,
    this.enabled = true,
    super.key,
  });

  final bool? border;
  final Color? color;
  final Widget? leadingIcon;
  final String? mainTitle;
  final String? upperTitle;
  final Color? upperTitleColor;
  final String? secondLowerTitle;
  final String? secondUpperTitle;
  final void Function()? onPressed;
  final Color? textColor;
  final double? fontSize;
  final Widget? trailingIcon;
  final double? buttonHeight;
  final Widget? titleWidget;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight ?? 48,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shape: border == null
              ? null
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.darkGrey),
                ),
          backgroundColor: enabled
              ? color ?? Theme.of(context).primaryColor
              : AppColors.darkGrey,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              SizedBox(height: 16, child: leadingIcon),
              const SizedBox(width: 8),
            ],
            if (trailingIcon != null)
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (upperTitle != null)
                      Text(
                        upperTitle!,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: upperTitleColor ?? textColor,
                        ),
                      ),
                    if (mainTitle != null)
                      Text(
                        mainTitle!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: enabled ? textColor : AppColors.lightBlack,
                          fontSize: fontSize,
                        ),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (upperTitle != null)
                      Text(
                        upperTitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: upperTitleColor ?? textColor,
                        ),
                      ),
                    if (mainTitle != null)
                      Text(
                        mainTitle!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: enabled ? textColor : AppColors.lightBlack,
                          fontSize: fontSize,
                        ),
                      ),
                  ],
                ),
              ),
            if (secondLowerTitle != null || secondUpperTitle != null) ...[
              if (trailingIcon != null) const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (secondUpperTitle != null)
                    Text(
                      secondUpperTitle!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: textColor),
                      maxLines: 1,
                    ),
                  if (secondLowerTitle != null)
                    Text(
                      secondLowerTitle!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: textColor),
                    ),
                ],
              ),
            ],
            if (titleWidget != null) Expanded(flex: 2, child: titleWidget!),
            if (trailingIcon != null) ...[
              if (secondLowerTitle == null &&
                  secondUpperTitle == null &&
                  titleWidget == null)
                const Spacer(),
              const SizedBox(width: 8),
              trailingIcon!,
            ],
          ],
        ),
      ),
    );
  }
}
