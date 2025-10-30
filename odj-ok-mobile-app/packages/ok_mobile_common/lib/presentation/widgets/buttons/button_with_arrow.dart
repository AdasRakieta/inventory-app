part of '../../../ok_mobile_common.dart';

class ButtonWithArrow extends StatelessWidget {
  const ButtonWithArrow({
    required this.title,
    this.onPressed,
    this.height,
    this.maxLines,
    super.key,
    this.style,
  });

  final void Function()? onPressed;
  final double? height;
  final String title;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          padding: const EdgeInsets.only(left: 16, right: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    style ??
                    Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                maxLines: maxLines,
                textAlign: TextAlign.center,
              ),
            ),
            IconContainer(
              child: Assets.icons.next.image(
                package: 'ok_mobile_common',
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
