part of '../../ok_mobile_counting_center.dart';

class ReceivalDetailsScreen extends StatefulWidget {
  const ReceivalDetailsScreen({
    required this.pickupId,
    required this.backRoute,
    super.key,
  });

  static const routeName = '/receival_details';
  static const pickupIdParam = 'pickupId';
  static const backRouteParam = 'backRoute';

  final String pickupId;
  final String backRoute;

  @override
  State<ReceivalDetailsScreen> createState() => _ReceivalDetailsScreenState();
}

class _ReceivalDetailsScreenState extends State<ReceivalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReceivalsCubit>().getReceivalData(widget.pickupId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ReceivalsCubit, ReceivalsState>(
        builder: (context, state) {
          final selectedReceival = state.selectedReceival;
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
                            selectedReceival == null)
                          const SizedBox.shrink()
                        else ...[
                          PickupButton(
                            title: selectedReceival.code!,
                            date: selectedReceival.dateAdded,
                            pickupStatus: selectedReceival.status!,
                            amountOfBags: selectedReceival.totalBags,
                            collectionPoint: selectedReceival.collectionPoint,
                            onPressed: () {
                              context.pushNamed(
                                ReceivalUneditableOverviewScreen.routeName,
                              );
                            },
                          ),
                          PackageQuantityWidget(
                            petQuantity: selectedReceival.petQuantity,
                            canQuantity: selectedReceival.canQuantity,
                          ),
                          const AppDivider(),
                          Builder(
                            builder: (context) {
                              return OkStepper(
                                collectionPointName:
                                    selectedReceival.collectionPoint?.name ??
                                    '',
                                countingCenterName:
                                    selectedReceival.countingCenter?.name ?? '',
                                statusHistory:
                                    selectedReceival.statusHistoryWithCurrent,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const AppDivider(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () {
                      context.goNamed(widget.backRoute);
                    },

                    text: S.current.back,
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
