part of '../../ok_mobile_pickups.dart';

class PickupsManagementScreen extends StatelessWidget {
  const PickupsManagementScreen({super.key});

  static const routeName = '/pickups_management';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.pickups),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<PickupsCubit, PickupsState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.selectedBags.isNotEmpty) ...[
                          SummaryWidget(
                            upperTitle: S.current.current_release,
                            numberToShow: state.selectedBags.length,
                            title: S.current.pickup_summary,
                            onPressed: () {
                              context.goNamed(
                                PickupOverviewScreen.routeName,
                                pathParameters: {
                                  PickupOverviewScreen.backRouteParam:
                                      PickupsManagementScreen.routeName,
                                },
                              );
                            },
                          ),
                          const AppDivider(),
                        ],
                        IconTextButton(
                          fontSize: 13,
                          icon: Assets.icons.clipboard.image(
                            package: 'ok_mobile_common',
                          ),
                          onPressed: () {
                            context.goNamed(DriverPickupScreen.routeName);
                          },
                          text: S.current.handing_over_driver,
                        ),
                        const SizedBox(height: 8),
                        IconTextButton(
                          fontSize: 13,
                          icon: Assets.icons.archive.image(
                            package: 'ok_mobile_common',
                          ),
                          onPressed: () {
                            context.goNamed(PickupsListScreen.routeName);
                          },
                          text: S.current.pickups_overview,
                        ),
                      ],
                    ),
                  ),
                  const AppDivider(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () => context.goNamed(MainScreen.routeName),
                    text: S.current.exit,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
