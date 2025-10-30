part of '../../../ok_mobile_common.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    required this.identity,
    required this.initialLanguage,
    required this.onLanguageChange,
    super.key,
  });

  final String identity;
  final Locale initialLanguage;
  final void Function(Locale locale) onLanguageChange;

  @override
  Widget build(BuildContext context) {
    return BaseAppBar(
      actions: [
        const SizedBox(width: 8),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Text(
              identity,
              style: AppTextStyle.microBold(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Assets.icons.okLogo.image(
          package: 'ok_mobile_common',
          color: AppColors.green,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
