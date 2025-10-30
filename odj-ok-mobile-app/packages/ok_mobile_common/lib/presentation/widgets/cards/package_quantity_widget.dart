part of '../../../ok_mobile_common.dart';

class PackageQuantityWidget extends StatelessWidget {
  const PackageQuantityWidget({
    required this.petQuantity,
    required this.canQuantity,
    this.title,
    super.key,
  });

  final int petQuantity;
  final int canQuantity;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(color: AppColors.black),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.grey,
        ),
        margin: const EdgeInsets.only(top: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: AppColors.black),
                ),
                const AppDivider(color: AppColors.darkGrey),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.current.pet_quantity),
                  Text(petQuantity.toString()),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.current.can_quantity),
                  Text(canQuantity.toString()),
                ],
              ),
              const AppDivider(color: AppColors.darkGrey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.current.total_quantity),
                  Text(
                    (petQuantity + canQuantity).toString(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
