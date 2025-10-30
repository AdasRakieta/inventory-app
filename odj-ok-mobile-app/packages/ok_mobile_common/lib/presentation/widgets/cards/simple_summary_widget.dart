part of '../../../ok_mobile_common.dart';

class SimpleSummaryWidget extends StatelessWidget {
  const SimpleSummaryWidget({
    required this.title,
    required this.quantity,
    super.key,
  });
  final String title;
  final int? quantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyle.h5()),
        if (quantity != null) ...[
          const Spacer(),
          Text('${S.current.pieces}:', style: AppTextStyle.micro()),
          const SizedBox(width: 8),
          PackageNumberWidget(
            numberToShow: quantity!,
            textColor: AppColors.black,
            margin: const EdgeInsets.only(right: 16),
          ),
        ],
      ],
    );
  }
}
