part of '../../ok_mobile_bags.dart';

class BagsToChangeSealListScreen extends StatefulWidget {
  const BagsToChangeSealListScreen({super.key});

  static const routeName = '/change_bag_seal_list';

  @override
  State<BagsToChangeSealListScreen> createState() =>
      _BagsToChangeSealListScreenState();
}

class _BagsToChangeSealListScreenState
    extends State<BagsToChangeSealListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<BagsCubit>().fetchClosedBags();
      if (mounted) {
        context.read<BagsCubit>().getBagsAndSaveToState(
          selectedStates: [BagState.closed],
          selectedTypes: [],
        );
        context.read<BagsCubit>().clearSelectedBag();
      }
    });
  }

  Future<bool> onScan(String value) async {
    final bag = context.read<BagsCubit>().getBagBySeal(
      value,
      showSnackBar: true,
      customMessage: S.current.bag_selected_for_seal_change,
    );
    if (bag != null) {
      context.goNamed(ChangeBagSealScreen.routeName);
      return true;
    }
    return false;
  }

  Future<void> _onPressed(Bag bag) async {
    context.read<BagsCubit>().selectBag(
      bag: bag,
      showSnackBar: true,
      customMessage: S.current.bag_selected_for_seal_change,
    );
    Future.delayed(Durations.extralong2, () {
      if (mounted) {
        context.goNamed(ChangeBagSealScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bagsState = context.watch<BagsCubit>().state;
    final hasSegregation = context.select<DeviceConfigCubit, bool>(
      (cubit) => cubit.state.collectionPointData?.segregatesItems ?? false,
    );
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.change_seal),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SealScannerWidget(
                title: S.current.scan_seal_or_pick_from_list,
                onScanSuccess: onScan,
              ),
              const AppDivider(),
              if (hasSegregation)
                PackageTypeFilters(
                  selectedBagTypes: bagsState.selectedBagTypes,
                  onPetFilterChanged: (value) {
                    context.read<BagsCubit>().changeTypeFilter(
                      type: BagType.plastic,
                      bagStates: [BagState.closed],
                    );
                  },
                  onCanFilterChanged: (value) {
                    context.read<BagsCubit>().changeTypeFilter(
                      type: BagType.can,
                      bagStates: [BagState.closed],
                    );
                  },
                ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    (bagsState.bagsToShow.isEmpty &&
                        bagsState.state == GeneralState.loaded)
                    ? NoItemsWidget(title: S.current.no_bags_to_display)
                    : Builder(
                        builder: (context) {
                          final bags = bagsState.bagsSorted
                              .where((bag) => bag.seal != null)
                              .toList();

                          final splices = BagsHelper.createBagSplices(bags);

                          final buttonsSegments = <List<Widget>>[];
                          final titles = <Widget>[];

                          for (final element in splices) {
                            titles.add(
                              Text(
                                DateFormat('dd.MM.yyyy').format(
                                  element.first.openedTime ?? DateTime.now(),
                                ),
                                style: AppTextStyle.smallBold(),
                              ),
                            );

                            buttonsSegments.add(
                              element.map((bag) {
                                return ClosedBagButton(
                                  bag: bag,
                                  onPressed: () => _onPressed(bag),
                                  isSelected:
                                      bag.id == bagsState.selectedBag?.id,
                                );
                              }).toList(),
                            );
                          }
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SegmentedButtonsColumn(
                                  buttonsSegments: buttonsSegments,
                                  segmentTitles: titles,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const AppDivider(verticalPadding: 0),
              NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () =>
                    context.goNamed(BagsManagementScreen.routeName),
                text: S.current.exit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
