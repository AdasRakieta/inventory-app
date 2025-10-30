part of '../../../ok_mobile_common.dart';

class CardQuantityWidget extends StatelessWidget {
  const CardQuantityWidget({
    required this.quantity,

    this.borderColor,
    super.key,
  });

  final int quantity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${S.current.pieces}:',
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: AppColors.black, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PackageNumberWidget(
              numberToShow: quantity,
              textColor: AppColors.black,
              borderColor: borderColor ?? AppColors.darkGrey,
            ),
          ],
        ),
      ],
    );
  }
}
