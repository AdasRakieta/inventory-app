part of '../../ok_mobile_bags.dart';

class PackageInfoCard extends StatelessWidget {
  const PackageInfoCard({
    required this.ean,
    required this.title,
    required this.numberOfPackages,
    required this.backgroundColor,
    this.subtitle,
    super.key,
  });

  final String ean;
  final String title;
  final String? subtitle;
  final int numberOfPackages;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${S.current.ean}: $ean', style: AppTextStyle.micro()),
                const SizedBox(height: 2),
                Text(title, style: AppTextStyle.pBold(), maxLines: 1),
                if (subtitle != null) ...[
                  AppDivider(color: secondaryColor, verticalPadding: 2),
                  Text(subtitle!, style: AppTextStyle.pBold()),
                ] else
                  const SizedBox(height: 34),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text('${S.current.pieces}:', style: AppTextStyle.micro()),
              const SizedBox(height: 4),
              PackageNumberWidget(
                numberToShow: numberOfPackages,
                textColor: AppColors.black,
                borderColor: secondaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get secondaryColor => backgroundColor == AppColors.paleGreen
      ? AppColors.green
      : AppColors.darkGrey;
}
