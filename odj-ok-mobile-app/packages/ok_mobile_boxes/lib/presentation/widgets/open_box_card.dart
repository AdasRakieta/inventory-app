part of '../../../ok_mobile_boxes.dart';

class OpenBoxCard extends StatelessWidget {
  const OpenBoxCard({required this.box, super.key});

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
            child: Assets.icons.packageOpen.image(
              package: 'ok_mobile_common',
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.open.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.yellow),
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
          PackageNumberWidget(numberToShow: box.bags.length),
        ],
      ),
    );
  }
}
