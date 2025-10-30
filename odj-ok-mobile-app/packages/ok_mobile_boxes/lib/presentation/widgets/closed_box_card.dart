part of '../../../ok_mobile_boxes.dart';

class ClosedBoxCard extends StatelessWidget {
  const ClosedBoxCard({required this.box, super.key});

  final Box box;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            height: 16,
            child: Assets.icons.package.image(
              package: 'ok_mobile_common',
              color: AppColors.lightGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.closed.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.lightGreen),
                ),
                Text(
                  box.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          Text(
            DatesHelper.formatDateTimeTwoLines(
              box.dateClosed ?? DateTime.now(),
            ),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(width: 8),
          PackageNumberWidget(numberToShow: box.bags.length),
        ],
      ),
    );
  }
}
