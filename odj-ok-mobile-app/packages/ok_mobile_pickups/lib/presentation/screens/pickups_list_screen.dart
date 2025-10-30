part of '../../ok_mobile_pickups.dart';

class PickupsListScreen extends StatefulWidget {
  const PickupsListScreen({super.key});

  static const routeName = '/pickups_list';

  @override
  State<PickupsListScreen> createState() => _PickupsListScreenState();
}

class _PickupsListScreenState extends State<PickupsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PickupsCubit>().fetchPickups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.pickups_overview),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BlocBuilder<PickupsCubit, PickupsState>(
                  builder: (context, state) {
                    if (state.pickups.isEmpty &&
                        state.state == GeneralState.loaded) {
                      return NoItemsWidget(title: S.current.no_pickups);
                    } else {
                      final splices = state.pickups.splitAfterIndexed(
                        (index, pickup) =>
                            index == state.pickups.length - 1 ||
                            !DatesHelper.isTheSameDay(
                              state.pickups[index].dateAdded,
                              state.pickups[index + 1].dateAdded,
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
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: AppColors.black),
                          ),
                        );

                        buttonsSegments.add(
                          element
                              .map(
                                (pickup) => PickupButton(
                                  amountOfBags: pickup.bagsCount,
                                  onPressed: () {
                                    context.goNamed(
                                      PickupDetailsScreen.routeName,
                                      pathParameters: {
                                        PickupDetailsScreen.pickupIdParam:
                                            pickup.id!,
                                      },
                                    );
                                  },
                                  title: pickup.code!,
                                  pickupStatus: pickup.status!,
                                  date: pickup.dateModified ?? pickup.dateAdded,
                                ),
                              )
                              .toList(),
                        );
                      }
                      return SingleChildScrollView(
                        child: SegmentedButtonsColumn(
                          buttonsSegments: buttonsSegments,
                          segmentTitles: titles,
                        ),
                      );
                    }
                  },
                ),
              ),
              const AppDivider(),
              NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () =>
                    context.goNamed(PickupsManagementScreen.routeName),
                text: S.current.exit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
