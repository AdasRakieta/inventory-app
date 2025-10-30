part of '../../../ok_mobile_common.dart';

class BaseBagButton extends StatelessWidget {
  const BaseBagButton({
    required this.onPressed,
    required this.leadingIcon,
    required this.title,
    required this.titleColor,
    required this.bodyText,
    required this.numberOfPackages,
    required this.backgroundColor,
    this.isSelected = false,
    this.subtitle,
    this.dateTime,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isSelected;

  final Image leadingIcon;
  final String title;
  final Color titleColor;
  final String bodyText;
  final String? subtitle;
  final DateTime? dateTime;
  final int numberOfPackages;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor.withValues(
            alpha: isSelected ? 0.85 : 1.0,
          ),
          disabledBackgroundColor: backgroundColor.withValues(
            alpha: isSelected ? 0.85 : 1.0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Row(
          children: [
            leadingIcon,
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      title.toUpperCase(),
                      style: AppTextStyle.microBold(color: titleColor),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    child: Text(
                      bodyText,
                      style: AppTextStyle.smallBold(color: AppColors.white),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (subtitle != null)
                    FittedBox(
                      child: Text(
                        subtitle!,
                        style: AppTextStyle.micro(color: AppColors.white),
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              DatesHelper.formatDateTimeTwoLines(dateTime ?? DateTime.now()),
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(fontSize: 10),
            ),
            const SizedBox(width: 8),
            PackageNumberWidget(numberToShow: numberOfPackages),
          ],
        ),
      ),
    );
  }
}
