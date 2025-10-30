part of '../../ok_mobile_admin.dart';

class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    context.watch<LocalizationCubit>();
    final hidePrinterConfig =
        context.read<DeviceConfigCubit>().isDigitalVoucherFlow ||
        (context.read<UserCubit>().state.user?.isCountingCenterUser ?? false);
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(
          title: S.current.settings,
          showSettings: false,
          blockReturnToHome: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  const LanguageButtons(
                    locales: [Locale('pl'), Locale('uk'), Locale('en')],
                  ),
                  const AppDivider(),
                  if (hidePrinterConfig)
                    const SizedBox.shrink()
                  else ...[
                    NavigationButton(
                      icon: Assets.icons.printer.image(
                        package: 'ok_mobile_common',
                        color: AppColors.green,
                      ),
                      onPressed: () {
                        context.pushNamed(PrinterConfigScreen.routeName);
                      },
                      text: S.current.printer_config,
                    ),
                    const AppDivider(),
                  ],
                  NavigationButton(
                    icon: Assets.icons.exit.image(package: 'ok_mobile_common'),
                    onPressed: () async {
                      final shouldLogout = await context
                          .read<AuthCubit>()
                          .signOut();
                      if (context.mounted && shouldLogout) {
                        await LogoutHelper.onLogoutCleanup(context);
                      }
                    },
                    text: S.current.logout,
                  ),
                ],
              ),
              const Spacer(),
              const AppDivider(),
              NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () {
                  context.pop();
                },
                text: S.current.back,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
