part of '../../ok_mobile_boxes.dart';

class ClosedBoxButton extends StatelessWidget {
  const ClosedBoxButton({
    required this.onPressed,
    required this.box,
    this.icon,
    super.key,
  });

  final VoidCallback onPressed;
  final Box box;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      leadingIcon: Assets.icons.package.image(
        package: 'ok_mobile_common',
        color: AppColors.lightGreen,
      ),
      onPressed: onPressed,
      color: AppColors.darkGreen,
      upperTitle: S.current.closed.toUpperCase(),
      upperTitleColor: AppColors.lightGreen,
      mainTitle: box.label,
      titleWidget: Text(
        DatesHelper.formatDateTimeTwoLines(box.dateClosed ?? DateTime.now()),
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailingIcon: IconContainer(
        child:
            icon ??
            Assets.icons.label.image(
              color: AppColors.black,
              package: 'ok_mobile_common',
              height: 16,
            ),
      ),
    );
  }
}
