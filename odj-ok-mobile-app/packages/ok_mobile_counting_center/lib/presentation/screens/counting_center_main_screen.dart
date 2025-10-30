part of '../../ok_mobile_counting_center.dart';

class CountingCenterMainScreen extends StatelessWidget {
  const CountingCenterMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final useMasterdataV2 =
        context
            .read<DeviceConfigCubit>()
            .state
            .remoteConfiguration
            .masterDataV2FeatureFlag;
    context.read<MasterDataCubit>().fetchMasterData(
      useMasterdataV2: useMasterdataV2,
    );
    final currentReceival =
        context.watch<ReceivalsCubit>().state.currentReceival;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (currentReceival != null &&
                  currentReceival.bags!.isNotEmpty) ...[
                SummaryWidget(
                  numberToShow: currentReceival.bags!.length,
                  title: S.current.receival_summary,
                  upperTitle: S.current.current_receival,
                  onPressed: () {
                    context.go(CCPackageReceivalScreen.routeName);
                  },
                ),
                const AppDivider(),
              ] else ...[
                IconTextButton(
                  fontSize: 13,
                  icon: Assets.icons.acceptance.image(
                    package: 'ok_mobile_common',
                  ),
                  onPressed: () {
                    context.go(CCPackageReceivalScreen.routeName);
                  },
                  text: S.current.package_receival,
                ),
                const SizedBox(height: 8),
              ],
              ButtonsColumn(
                buttons: [
                  IconTextButton(
                    fontSize: 13,
                    icon: Assets.icons.pickup.image(
                      package: 'ok_mobile_common',
                    ),
                    onPressed: () {
                      context.go(CCPlannedReceivalsScreen.routeName);
                    },
                    text: S.current.planned_receival,
                  ),
                  IconTextButton(
                    fontSize: 13,
                    icon: Assets.icons.archive.image(
                      package: 'ok_mobile_common',
                    ),
                    onPressed: () {
                      context.go(CCCollectedReceivalsScreen.routeName);
                    },
                    text: S.current.receival_tally,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
