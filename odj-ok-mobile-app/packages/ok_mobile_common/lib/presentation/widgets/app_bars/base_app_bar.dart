part of '../../../ok_mobile_common.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    this.actions,
    this.leading,
    this.title,
    this.showSettings = true,
    this.isColectionPointNumberVisible = true,
    this.blockReturnToHome = false,
    super.key,
  });

  final List<Widget>? actions;
  final Widget? leading;
  final String? title;
  final bool showSettings;
  final bool isColectionPointNumberVisible;
  final bool blockReturnToHome;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        ...?actions,
        if (isColectionPointNumberVisible)
          Builder(
            builder: (context) {
              final deviceConfigState = context
                  .watch<DeviceConfigCubit>()
                  .state;
              final deviceConfig = deviceConfigState.deviceConfig;
              final chipContent = deviceConfig != null
                  ? deviceConfig.isCollectionPoint
                        ? deviceConfig.collectionPointCode
                        : deviceConfigState.contractorData?.addressCity
                  : null;
              return chipContent != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: LimitedBox(
                        maxWidth: 50,
                        child: AutoSizeText(
                          maxLines: 1,
                          minFontSize: 9,
                          chipContent,
                          style: AppTextStyle.microBold(),
                          overflowReplacement: Tooltip(
                            message: chipContent,
                            decoration: const BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            textStyle: const TextStyle(color: AppColors.black),
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              chipContent,
                              style: AppTextStyle.microBold(),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        if (showSettings)
          IconButton(
            onPressed: () {
              context.pushNamed(SettingsMainScreen.routeName);
            },
            visualDensity: VisualDensity.compact,
            icon: Assets.icons.settings.image(
              package: 'ok_mobile_common',
              width: 18,
              height: 18,
            ),
            style: IconButton.styleFrom(splashFactory: NoSplash.splashFactory),
          ),
        SizedBox(width: showSettings ? 10 : 20),
      ],
      backgroundColor: AppColors.white,
      elevation: 1,
      leading: leading,
      shadowColor: AppColors.darkGrey,
      title: title != null
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(title!, style: AppTextStyle.smallBold(), maxLines: 2),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
