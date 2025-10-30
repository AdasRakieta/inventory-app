part of '../../../ok_mobile_returns.dart';

class MainScreenErrorCard extends StatelessWidget {
  const MainScreenErrorCard({required this.failure, super.key});

  final Failure failure;

  String get resolveUpperTitle => switch (failure.type) {
    FailureType.wrongDeviceAssignmentToCollectionPoint =>
      S.current.wrong_device_to_collection_point,
    FailureType.wrongDeviceAssignmentToCountingCenter =>
      S.current.wrong_device_to_cc,
    FailureType.wrongDeviceAssignmentToRetailChain =>
      S.current.wrong_device_to_retail_chain,
    FailureType.wrongUserAssignmentToCollectionPoint =>
      S.current.wrong_user_to_collection_point,
    FailureType.wrongUserAssignmentToCountingCenter =>
      S.current.wrong_user_to_cc,
    FailureType.wrongUserAssignmentToRetailChain =>
      S.current.wrong_user_to_retail_chain,
    FailureType.noAccess => S.current.no_access_contact_admin,
    FailureType.wrongUserConfiguration => S.current.wrong_user_configuration,
    _ => S.current.device_not_configured,
  };

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: AlertCard(
                text: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(textAlign: TextAlign.center, resolveUpperTitle),
                ),
                subText: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    S.current.contact_admin,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.lightGreen,
                    ),
                  ),
                ),
                icon: Assets.icons.warning.image(
                  package: 'ok_mobile_common',
                  height: 40,
                ),
              ),
            ),
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: NavigationButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
