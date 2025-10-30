part of '../../../ok_mobile_common.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.text,
    required this.icon,
    this.subText,
    this.backgroundColor = AppColors.darkGreen,
    super.key,
  });

  final Widget text;
  final Widget? subText;
  final Widget icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppColors.darkGreen,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            text,
            if (subText != null) ...[const SizedBox(height: 8), subText!],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
