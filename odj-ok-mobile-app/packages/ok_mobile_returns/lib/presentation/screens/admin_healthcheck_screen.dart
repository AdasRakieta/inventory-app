part of '../../ok_mobile_returns.dart';

class AdminHealthcheckScreen extends StatelessWidget {
  const AdminHealthcheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${S.current.environment} '
                    '${getIt<AppConfigProvider>().environment}}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.current.if_you_see_this_screen,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            LoggerService().trackTrace(
                              'Healthcheck Test',
                              message: 'Healthcheck Test Successful',
                              severity: Severity.information,
                              bypassLoggingLevel: true,
                              shouldFlush: true,
                              properties: {
                                'time': DatesHelper.formatDateTimeOneLine(
                                  DateTime.now(),
                                ),
                                'type': 'mobile_healthcheck',
                              },
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBarHelper.successSnackBarWidget(
                                message: S.current.insights_request_sent,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            S.current.test_application_insights,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const AppDivider(),
            NavigationButton(
              icon: Assets.icons.exit.image(package: 'ok_mobile_common'),
              onPressed: () async {
                final shouldLogout = await context.read<AuthCubit>().signOut();
                if (context.mounted && shouldLogout) {
                  await LogoutHelper.onLogoutCleanup(context);
                }
              },
              text: S.current.logout,
            ),
          ],
        ),
      ),
    );
  }
}
