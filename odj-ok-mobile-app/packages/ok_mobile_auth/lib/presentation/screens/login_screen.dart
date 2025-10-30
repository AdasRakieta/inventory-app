part of '../../ok_mobile_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  Future<void> initialize(BuildContext context) async {
    context.read<UserCubit>().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        child: BlocBuilder<LocalizationCubit, LocalizationState>(
          builder: (context, localizationState) {
            final currentLocale = localizationState.currentLocale;
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
                          Assets.icons.okLogo.image(
                            package: 'ok_mobile_common',
                            width: 100,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            S.current.welcome_to_system,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            '${S.current.ok_name}!',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const AppDivider(color: AppColors.green),
                          BlocListener<AuthCubit, AuthState>(
                            listener: (context, state) {
                              if (state.authStatus ==
                                  AuthStatus.authenticated) {
                                initialize(context);
                              }
                            },
                            child: SizedBox(
                              width: 140,
                              child: ButtonWithArrow(
                                height: 36,
                                key: const ValueKey('auth_screen_login_button'),
                                title: S.current.log_in,
                                onPressed: () async {
                                  switch (getIt<AppConfigProvider>()
                                      .configType) {
                                    case ConfigType.lidl:
                                      final redirectResponse = await context
                                          .push<String>(
                                            InAppAuthScreen.routeName,
                                          );

                                      if (redirectResponse != null &&
                                          context.mounted) {
                                        await context
                                            .read<AuthCubit>()
                                            .authenticateInApp(
                                              redirectReponse: redirectResponse,
                                              languageCode:
                                                  currentLocale.languageCode,
                                            );
                                      }

                                    case _:
                                      await context
                                          .read<AuthCubit>()
                                          .authenticate(
                                            currentLocale.languageCode,
                                          );
                                  }
                                },
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Footer(),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    child: LanguageButton(
                      initialLocale: localizationState.currentLocale,
                      onLanguageChange: (locale) {
                        context.read<LocalizationCubit>().changeLocale(locale);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
