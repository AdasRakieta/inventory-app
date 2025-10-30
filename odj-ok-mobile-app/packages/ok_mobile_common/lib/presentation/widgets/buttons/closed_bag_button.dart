part of '../../../ok_mobile_common.dart';

class ClosedBagButton extends StatelessWidget {
  /// when onPressed is null, the button is not clickable
  const ClosedBagButton({
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
      leadingIcon: Assets.icons.bagClosed.image(
        package: 'ok_mobile_common',
        color: AppColors.lightGreen,
        height: 16,
      ),
      title: bag.type.title(isOpen: false),
      titleColor: AppColors.lightGreen,
      bodyText: '${S.current.seal}: ${bag.seal}',
      subtitle: '${S.current.label}: ${bag.label}',
      numberOfPackages:
          bag.itemsCount ??
          ReturnsHelper.getNumberOfAllPackages(openedReturn, bag),
      backgroundColor: BagsHelper.resolveColor(bag.type),
      dateTime: bag.closedTime,
      isSelected: isSelected,
    );
  }
}
