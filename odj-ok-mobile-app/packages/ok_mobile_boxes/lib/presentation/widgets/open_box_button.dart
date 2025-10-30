part of '../../ok_mobile_boxes.dart';

class OpenBoxButton extends StatelessWidget {
  const OpenBoxButton({
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
      leadingIcon: Assets.icons.packageOpen.image(
        package: 'ok_mobile_common',
        color: AppColors.yellow,
      ),
      onPressed: onPressed,
      color: AppColors.darkGreen,
      upperTitle: S.current.open.toUpperCase(),
      upperTitleColor: AppColors.yellow,
      mainTitle: box.label,
      titleWidget: Row(
        children: [
          const Spacer(),
          PackageNumberWidget(numberToShow: box.bags.length),
        ],
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
