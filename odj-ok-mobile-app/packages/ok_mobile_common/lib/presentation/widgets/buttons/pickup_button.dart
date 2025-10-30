part of '../../../ok_mobile_common.dart';

class PickupButton extends StatelessWidget {
  const PickupButton({
    required this.title,
    required this.date,
    required this.pickupStatus,
    this.collectionPoint,
    this.onPressed,
    this.amountOfBags,
    this.withSplashEffect = true,
    super.key,
  });

  final String title;
  final DateTime date;
  final PickupStatus pickupStatus;
  final ContractorData? collectionPoint;
  final void Function()? onPressed;
  final int? amountOfBags;
  final bool withSplashEffect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          splashFactory: withSplashEffect ? null : NoSplash.splashFactory,
          overlayColor: withSplashEffect ? null : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: pickupStatus == PickupStatus.released
              ? AppColors.lightGreen
              : Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 16,
              child: Assets.icons.pickup.image(
                package: 'ok_mobile_common',
                color: _resolveColor(pickupStatus),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pickupStatus.localizedName.toUpperCase(),
                    style: AppTextStyle.microBold(
                      color: _resolveColor(pickupStatus),
                    ),
                  ),
                  Text(
                    title,
                    style: AppTextStyle.pBold(
                      color: pickupStatus == PickupStatus.released
                          ? null
                          : AppColors.white,
                    ),
                  ),
                  if (collectionPoint != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Assets.icons.mapPin.image(
                          package: 'ok_mobile_common',
                          height: 10,
                          color: _resolveColor(pickupStatus),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          collectionPoint!.name,
                          style: AppTextStyle.micro(
                            color: pickupStatus == PickupStatus.released
                                ? null
                                : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Text(
              DatesHelper.formatDateTimeTwoLines(date),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 10,
                color: pickupStatus == PickupStatus.released
                    ? AppColors.black
                    : null,
              ),
            ),
            if (amountOfBags != null) ...[
              const SizedBox(width: 8),
              PackageNumberWidget(
                borderColor: pickupStatus == PickupStatus.released
                    ? AppColors.green
                    : AppColors.white,
                numberToShow: amountOfBags!,
                textColor: pickupStatus == PickupStatus.released
                    ? AppColors.black
                    : AppColors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color? _resolveColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.released:
        return AppColors.green;
      case PickupStatus.partiallyReceived:
        return AppColors.yellow;
      case PickupStatus.received:
        return AppColors.lightGreen;
      case PickupStatus.futureReceived:
        return AppColors.lightGrey;
    }
  }
}
