part of '../../../ok_mobile_common.dart';

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({
    required this.numberToShow,
    required this.onPressed,
    this.title,
    this.upperTitle,
    this.enabled = true,
    this.fontSize,
    this.color = AppColors.darkGreen,
    super.key,
  });

  final int numberToShow;
  final VoidCallback onPressed;
  final String? title;
  final bool enabled;
  final double? fontSize;
  final String? upperTitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //TODO Decide we should show this when
        // all types are displayed because now
        // it looks bad
        Text(
          upperTitle ?? S.current.current_return,
          style: AppTextStyle.smallBold(),
        ),
        const SizedBox(height: 8),
        BaseButton(
          leadingIcon: Assets.icons.listChecks.image(
            package: 'ok_mobile_common',
            color: AppColors.lightGreen,
            height: 16,
          ),
          mainTitle: title ?? S.current.return_summary,
          fontSize: fontSize,
          trailingIcon: PackageNumberWidget(
            numberToShow: numberToShow,
            textColor: AppColors.white,
            margin: const EdgeInsets.only(right: 8),
          ),
          color: enabled ? color : AppColors.darkGrey,
          textColor: enabled ? Colors.white : AppColors.lightBlack,
          buttonHeight: 60,
          onPressed: enabled ? onPressed : null,
        ),
      ],
    );
  }
}
