part of '../../../ok_mobile_common.dart';

class PackageDetailsCard extends StatelessWidget {
  const PackageDetailsCard({
    required this.bagIdentifier,
    required this.description,
    required this.quantity,
    required this.ean,
    required this.backgroundColor,
    this.onDecrease,
    this.onRemove,
    this.enableEdit = true,
    this.isLabelOrSealVisible = true,
    super.key,
  });

  final String bagIdentifier;
  final String description;
  final int quantity;
  final String ean;
  final void Function()? onDecrease;
  final void Function()? onRemove;
  final bool enableEdit;
  final Color backgroundColor;
  final bool isLabelOrSealVisible;

  @override
  Widget build(BuildContext context) {
    final labelText =
        '${enableEdit ? S.current.label : S.current.seal}: $bagIdentifier';
    return Slidable(
      enabled: enableEdit,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          CustomSlidableAction(
            onPressed: (_) {
              switch (quantity) {
                case > 1:
                  onDecrease?.call();
                case 1:
                case <= 0:
                  onRemove?.call();
              }
            },
            backgroundColor: AppColors.red,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: quantity > 1
                ? const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.black,
                  )
                : Assets.icons.trash.image(
                    package: 'ok_mobile_common',
                    color: AppColors.black,
                    height: 16,
                  ),
          ),
        ],
      ),
      child: Container(
        decoration: enableEdit
            ? BoxDecoration(
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
                  stops: const [0, 0.98, 0.98, 2],
                ),
              )
            : BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: backgroundColor,
              ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${S.current.ean}: $ean',
                      textAlign: TextAlign.left,
                      style: AppTextStyle.micro(),
                    ),
                    const SizedBox(height: 2),
                    Text(description, style: AppTextStyle.pBold()),
                    if (isLabelOrSealVisible)
                      Column(
                        children: [
                          AppDivider(color: secondaryColor, verticalPadding: 0),
                          Row(
                            children: [
                              SizedBox(
                                height: 12,
                                child: enableEdit
                                    ? Assets.icons.bagOpen.image(
                                        package: 'ok_mobile_common',
                                      )
                                    : Assets.icons.bagClosed.image(
                                        package: 'ok_mobile_common',
                                        color: AppColors.green,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  labelText,
                                  style: AppTextStyle.micro(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: CardQuantityWidget(
                  quantity: quantity,
                  borderColor: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get secondaryColor => backgroundColor == AppColors.babyBlue
      ? AppColors.blue
      : backgroundColor == AppColors.paleGreen
      ? AppColors.green
      : AppColors.darkGrey;
}
