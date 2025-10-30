part of '../../ok_mobile_pickups.dart';

class PickupOverviewScreen extends StatelessWidget {
  const PickupOverviewScreen({required this.backRoute, super.key});

  static const routeName = '/pickup_overview';
  static const backRouteParam = 'backRoute';

  final String backRoute;

  @override
  Widget build(BuildContext context) {
    context.read<PickupsCubit>().updateBagsInActivePickup();
    return BlocBuilder<PickupsCubit, PickupsState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: GeneralAppBar(title: S.current.handing_over_driver),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleSummaryWidget(
                    title: S.current.current_release,
                    quantity: state.selectedBags.length,
                  ),
                  const SizedBox(height: 8),
                  SealScannerWidget(
                    title: S.current.scan_bag_seal_code_pickup,
                    onScanSuccess: (value) async {
                      final bag = context
                          .read<BagsCubit>()
                          .checkIfClosedBagExistsBySeal(
                            value,
                            considerBoxAssignment: false,
                          );

                      if (bag != null) {
                        final canBeAddedToPickup = context
                            .read<ReturnsCubit>()
                            .checkIfBagContainsOpenReturnPackages(bag);
                        if (canBeAddedToPickup) {
                          return context.read<PickupsCubit>().addBagToPickup(
                            bag,
                          );
                        }
                      }

                      return false;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.current.list_of_added_bags,
                    style: AppTextStyle.smallBold(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ClosableBagButtonList(
                        bags: state.selectedBags,
                        onRemove: context
                            .read<PickupsCubit>()
                            .removeBagFromPickup,
                      ),
                    ),
                  ),
                  const AppDivider(),
                  ButtonsRow(
                    buttons: [
                      Flexible(
                        child: NavigationButton(
                          icon: Assets.icons.back.image(
                            package: 'ok_mobile_common',
                          ),
                          onPressed: () => context.goNamed(backRoute),
                          text: S.current.exit,
                        ),
                      ),
                      Flexible(
                        child: IconTextButton(
                          enabled: state.selectedBags.isNotEmpty,
                          icon: Assets.icons.clipboard.image(
                            package: 'ok_mobile_common',
                            color: state.selectedBags.isNotEmpty
                                ? AppColors.black
                                : AppColors.lightBlack,
                          ),
                          onPressed: () {
                            context.pushNamed(
                              PickupConfirmationScreen.routeName,
                            );
                          },
                          text: S.current.confirm_pickup,
                          color: AppColors.yellow,
                          textColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
