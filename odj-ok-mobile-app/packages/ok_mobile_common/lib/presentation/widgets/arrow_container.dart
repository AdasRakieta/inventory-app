part of '../../../ok_mobile_common.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.yellow,
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}
