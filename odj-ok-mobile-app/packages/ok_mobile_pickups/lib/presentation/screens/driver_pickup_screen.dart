part of '../../ok_mobile_pickups.dart';

class DriverPickupScreen extends StatefulWidget {
  const DriverPickupScreen({super.key});

  static const routeName = '/driver_pickup';

  @override
  State<DriverPickupScreen> createState() => _DriverPickupScreenState();
}

class _DriverPickupScreenState extends State<DriverPickupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<BagsCubit>().fetchClosedBags();
    });
    context.read<PickupsCubit>().updateBagsInActivePickup();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PickupsCubit, PickupsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: GeneralAppBar(title: S.current.handing_over_driver),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              SimpleSummaryWidget(
                                title: S.current.current_release,
                                quantity: state.selectedBags.length,
                              ),
                              const SizedBox(height: 8),
                              SealScannerWidget(
                                title:
                                    S.current.scan_seal_and_add_bag_to_pickup,
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
                                        .checkIfBagContainsOpenReturnPackages(
                                          bag,
                                        );
                                    if (canBeAddedToPickup) {
                                      return context
                                          .read<PickupsCubit>()
                                          .addBagToPickup(bag);
                                    }
                                  }

                                  return false;
                                },
                              ),
                              if (state.selectedBags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  S.current.list_of_added_bags,
                                  style: AppTextStyle.smallBold(),
                                ),
                                const SizedBox(height: 8),

                                ClosableBagButtonList(
                                  bags: state.selectedBags,
                                  onRemove: context
                                      .read<PickupsCubit>()
                                      .removeBagFromPickup,
                                ),
                              ] else
                                NoItemsWidget(
                                  title: S.current.no_bags_in_current_pickup,
                                ),
                            ],
                          ),
                          Column(
                            children: [
                              const AppDivider(),
                              ButtonsRow(
                                buttons: [
                                  Expanded(
                                    child: NavigationButton(
                                      icon: Assets.icons.back.image(
                                        package: 'ok_mobile_common',
                                      ),
                                      onPressed: () {
                                        context.goNamed(
                                          PickupsManagementScreen.routeName,
                                        );
                                      },
                                      text: S.current.exit,
                                    ),
                                  ),
                                  Expanded(
                                    child: IconTextButton(
                                      enabled: state.selectedBags.isNotEmpty,
                                      color: AppColors.yellow,
                                      textColor: AppColors.black,
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
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
