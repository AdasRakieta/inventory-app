part of '../../../ok_mobile_common.dart';

class OpenBagButton extends StatelessWidget {
  /// when onPressed is null, the button is not clickable
  const OpenBagButton({
    required this.bag,
    this.onPressed,
    this.isSelected = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Bag bag;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final openedReturn = context.watch<ReturnsCubit>().state.openedReturn;
    return BaseBagButton(
      onPressed: onPressed,
      leadingIcon: Assets.icons.bagOpen.image(
        package: 'ok_mobile_common',
        color: AppColors.yellow,
        height: 16,
      ),
      title: bag.type.title(),
      titleColor: AppColors.yellow,
      bodyText: '${S.current.label}: ${bag.label}',
      numberOfPackages: ReturnsHelper.getNumberOfAllPackages(openedReturn, bag),
      backgroundColor: BagsHelper.resolveColor(bag.type),
      dateTime: bag.openedTime,
      isSelected: isSelected,
    );
  }
}
