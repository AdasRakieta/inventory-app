part of '../../ok_mobile_counting_center.dart';

class CCCollectedReceivalsScreen extends StatefulWidget {
  const CCCollectedReceivalsScreen({super.key});

  static const routeName = '/cc_completed_receivals';

  @override
  State<CCCollectedReceivalsScreen> createState() =>
      _CCCollectedReceivalsScreenState();
}

class _CCCollectedReceivalsScreenState
    extends State<CCCollectedReceivalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final countingCenterId =
          context.read<DeviceConfigCubit>().state.contractorData!.id;
      await context.read<ReceivalsCubit>().getCollectedReceivals(
        countingCenterId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.receival_tally),
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
                          petQuantity:
                              state.collectedReceivals?.petQuantity ?? 0,
                          canQuantity:
                              state.collectedReceivals?.canQuantity ?? 0,
                          title: S.current.collected_packages,
                        ),
                        const AppDivider(),
                        if (state.collectedReceivals!.ccPickups.isEmpty &&
                            state.state == GeneralState.loaded)
                          NoItemsWidget(title: S.current.no_receivals),
                        Builder(
                          builder: (context) {
                            final splices =
                                state.collectedReceivals!.ccPickups
                                    .splitAfterIndexed((index, pickup) {
                                      return index ==
                                              state
                                                      .collectedReceivals!
                                                      .ccPickups
                                                      .length -
                                                  1 ||
                                          !DatesHelper.isTheSameDay(
                                            state
                                                .collectedReceivals!
                                                .ccPickups[index]
                                                .dateAdded,
                                            state
                                                .collectedReceivals!
                                                .ccPickups[index + 1]
                                                .dateAdded,
                                          );
                                    })
                                    .toList();

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
                                              CCCollectedReceivalsScreen
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
