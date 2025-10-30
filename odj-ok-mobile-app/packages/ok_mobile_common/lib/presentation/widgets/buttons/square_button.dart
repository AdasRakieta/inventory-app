part of '../../../ok_mobile_common.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    required this.title,
    required this.icon,
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;
  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.darkGrey),
          ),

          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16, child: icon),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelSmall!.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
