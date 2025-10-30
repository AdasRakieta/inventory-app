part of '../../../ok_mobile_common.dart';

class CloseableBagButton extends StatelessWidget {
  const CloseableBagButton({
    required this.bag,
    this.onRemove,
    this.onPressed,
    super.key,
  });

  final Bag bag;
  final void Function()? onRemove;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = BagsHelper.resolveColor(bag.type);
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          CustomSlidableAction(
            onPressed: (_) {
              onRemove?.call();
            },
            backgroundColor: AppColors.red,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Assets.icons.trash.image(
              package: 'ok_mobile_common',
              color: AppColors.black,
              height: 16,
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              topLeft: Radius.circular(8),
            ),
            gradient: LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor,
                AppColors.red,
                AppColors.red,
              ],
              stops: const [0, 0.99, 0.99, 1],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Assets.icons.bagClosed.image(
                  package: 'ok_mobile_common',
                  color: AppColors.lightGreen,
                  height: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          bag.type.title(isOpen: false),
                          style: AppTextStyle.microBold(
                            color: AppColors.lightGreen,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        child: Text(
                          '${S.current.seal}: ${bag.seal}',
                          style: AppTextStyle.smallBold(color: AppColors.white),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        child: Text(
                          '${S.current.label}: ${bag.label}',
                          style: AppTextStyle.micro(color: AppColors.white),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DatesHelper.formatDateTimeTwoLines(
                    bag.closedTime ?? DateTime.now(),
                  ),
                  textAlign: TextAlign.right,
                  style: AppTextStyle.micro(color: AppColors.white),
                ),
                const SizedBox(width: 8),
                PackageNumberWidget(numberToShow: bag.numberOfPackages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
