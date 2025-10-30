part of '../../ok_mobile_returns.dart';

class ReturnButton extends StatelessWidget {
  const ReturnButton({
    required this.title,
    required this.date,
    required this.numberOfPackages,
    this.state,
    this.onPressed,
    super.key,
    this.showArrow = false,
    this.backgroundColor,
  });

  final String title;
  final DateTime date;
  final void Function()? onPressed;
  final bool showArrow;
  final ReturnState? state;
  final int numberOfPackages;
  final Color? backgroundColor;

  TextStyle? _returnStateTextStyle(BuildContext context) {
    switch (state) {
      case ReturnState.canceled:
        return AppTextStyle.microBold(color: AppColors.powderRed);
      case ReturnState.ongoing:
      case ReturnState.unfinished:
        return AppTextStyle.microBold(color: AppColors.yellow);
      case ReturnState.printed:
        return AppTextStyle.microBold(color: AppColors.lightGreen);
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.darkGrey),
          ),
          backgroundColor: backgroundColor ?? AppColors.darkGreen,
          disabledBackgroundColor: backgroundColor ?? AppColors.darkGreen,
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 16,
              child: ReturnsHelper.resolveLeadingIcon(state),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state != null)
                    Text(
                      ReturnsHelper.resolveReturnStateText(
                        state!,
                      ).toUpperCase(),
                      style: _returnStateTextStyle(context),
                    ),
                  Text(
                    title,
                    style: AppTextStyle.pBold(color: AppColors.white),
                  ),
                ],
              ),
            ),
            Text(
              DatesHelper.formatDateTimeTwoLines(date),
              textAlign: TextAlign.right,
              style: AppTextStyle.micro(color: AppColors.white),
            ),
            const SizedBox(width: 8),
            if (showArrow)
              IconContainer(
                child: Assets.icons.next.image(
                  package: 'ok_mobile_common',
                  height: 16,
                ),
              )
            else
              PackageNumberWidget(
                numberToShow: numberOfPackages,
                textColor: AppColors.white,
                borderColor: AppColors.white,
              ),
          ],
        ),
      ),
    );
  }
}
