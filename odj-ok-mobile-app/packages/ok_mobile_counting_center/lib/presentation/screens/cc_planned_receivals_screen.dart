part of '../../ok_mobile_counting_center.dart';

class CCPlannedReceivalsScreen extends StatefulWidget {
  const CCPlannedReceivalsScreen({super.key});

  static const routeName = '/cc_planned_receivals';

  @override
  State<CCPlannedReceivalsScreen> createState() =>
      _CCPlannedReceivalsScreenState();
}

class _CCPlannedReceivalsScreenState extends State<CCPlannedReceivalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final countingCenterId =
          context.read<DeviceConfigCubit>().state.contractorData!.id;
      await context.read<ReceivalsCubit>().getPlannedReceivals(
        countingCenterId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.planned_receival),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BlocBuilder<ReceivalsCubit, ReceivalsState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageQuantityWidget(
                          petQuantity: state.plannedReceivals?.petQuantity ?? 0,
                          canQuantity: state.plannedReceivals?.canQuantity ?? 0,
                          title: S.current.packages_on_the_way,
                        ),
                        const AppDivider(),
                        if (state.plannedReceivals!.ccPickups.isEmpty &&
                            state.state == GeneralState.loaded)
                          NoItemsWidget(title: S.current.no_receivals),
                        Builder(
                          builder: (context) {
                            final splices = state.plannedReceivals!.ccPickups
                                .splitAfterIndexed(
                                  (index, pickup) =>
                                      index ==
                                          state
                                                  .plannedReceivals!
                                                  .ccPickups
                                                  .length -
                                              1 ||
                                      !DatesHelper.isTheSameDay(
                                        state
                                            .plannedReceivals!
                                            .ccPickups[index]
                                            .dateAdded,
                                        state
                                            .plannedReceivals!
                                            .ccPickups[index + 1]
                                            .dateAdded,
                                      ),
                                );
                            final buttonsSegments = <List<Widget>>[];
                            final titles = <Widget>[];

                            for (final element in splices) {
                              titles.add(
                                Text(
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(element.first.dateAdded),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: AppColors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              );

                              buttonsSegments.add(
                                element.map((pickup) {
                                  return PickupButton(
                                    onPressed: () {
                                      context.goNamed(
                                        ReceivalDetailsScreen.routeName,
                                        pathParameters: {
                                          ReceivalDetailsScreen.pickupIdParam:
                                              pickup.id,
                                          ReceivalDetailsScreen.backRouteParam:
                                              CCPlannedReceivalsScreen
                                                  .routeName,
                                        },
                                      );
                                    },
                                    title: pickup.code,
                                    pickupStatus: pickup.status,
                                    date: pickup.dateAdded,
                                    collectionPoint: pickup.collectionPoint,
                                    amountOfBags: pickup.bagsCount,
                                  );
                                }).toList(),
                              );
                            }
                            return Expanded(
                              child: SingleChildScrollView(
                                child: SegmentedButtonsColumn(
                                  buttonsSegments: buttonsSegments,
                                  segmentTitles: titles,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const AppDivider(),
              NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () => context.goNamed(MainScreen.routeName),
                text: S.current.exit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
