part of '../../ok_mobile_pickups.dart';

class PickupDetailsScreen extends StatefulWidget {
  const PickupDetailsScreen({required this.pickupId, super.key});

  static const routeName = '/pickup_details';
  static const pickupIdParam = 'pickupId';

  final String pickupId;

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PickupsCubit>().getPickupData(widget.pickupId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PickupsCubit, PickupsState>(
        builder: (context, state) {
          final selectedPickup = state.selectedPickup;

          return Scaffold(
            appBar: GeneralAppBar(title: S.current.pickup_summary),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.state == GeneralState.loading ||
                            selectedPickup == null)
                          const SizedBox.shrink()
                        else ...[
                          PickupButton(
                            title: selectedPickup.code!,
                            date: selectedPickup.dateAdded,
                            pickupStatus: selectedPickup.status!,
                            amountOfBags: selectedPickup.totalBags,
                            onPressed: () => context.pushNamed(
                              PickupUneditableOverviewScreen.routeName,
                            ),
                          ),
                          PackageQuantityWidget(
                            petQuantity: selectedPickup.petQuantity,
                            canQuantity: selectedPickup.canQuantity,
                          ),
                          const AppDivider(),
                          Builder(
                            builder: (context) {
                              return OkStepper(
                                collectionPointName:
                                    selectedPickup.collectionPoint?.name ?? '',
                                countingCenterName:
                                    selectedPickup.countingCenter?.name ?? '',
                                statusHistory:
                                    selectedPickup.statusHistoryWithCurrent,
                              );
                            },
                          ),
                        ],
                      ],
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
                          onPressed: () =>
                              context.goNamed(PickupsListScreen.routeName),
                          text: S.current.back,
                        ),
                      ),
                      if (selectedPickup?.status == PickupStatus.released)
                        Flexible(
                          child: IconTextButton(
                            icon: Assets.icons.printer.image(
                              package: 'ok_mobile_common',
                            ),
                            color: AppColors.yellow,
                            textColor: AppColors.black,
                            text: S.current.print_pickup_confirmation,
                            onPressed: () => context
                                .read<PickupsCubit>()
                                .printPickupConfirmation(
                                  pickup: selectedPickup!,
                                  macAddress: context
                                      .read<AdminCubit>()
                                      .state
                                      .selectedPrinterMacAddress!,
                                  showSnackBar: true,
                                ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
