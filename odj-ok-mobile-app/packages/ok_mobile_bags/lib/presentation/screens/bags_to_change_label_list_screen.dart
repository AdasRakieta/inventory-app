part of '../../ok_mobile_bags.dart';

class BagsToChangeLabelListScreen extends StatefulWidget {
  const BagsToChangeLabelListScreen({super.key});

  static const routeName = '/change_label_bags_list';

  @override
  State<BagsToChangeLabelListScreen> createState() =>
      _BagsToChangeLabelListScreenState();
}

class _BagsToChangeLabelListScreenState
    extends State<BagsToChangeLabelListScreen> {
  bool showOpen = false;
  bool showClosed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<BagsCubit>().fetchClosedBags();
      if (mounted) {
        await context.read<BagsCubit>().fetchOpenBags();
      }
      if (mounted) {
        context.read<BagsCubit>().getBagsAndSaveToState(
          selectedStates: [BagState.open, BagState.closed],
          selectedTypes: [],
        );
        context.read<BagsCubit>().clearSelectedBag();
      }
    });
  }

  Future<bool> onScan(String value) async {
    final bag = context.read<BagsCubit>().getBagByLabel(
      value,
      successMessage: S.current.bag_selected_for_label_change,
    );
    if (bag != null) {
      Future.delayed(Durations.extralong2, () {
        if (mounted) {
          context.goNamed(ChangeBagLabelScreen.routeName);
        }
      });
      return true;
    }
    return false;
  }

  Future<void> _onPressed(Bag bag) async {
    context.read<BagsCubit>().selectBag(
      bag: bag,
      showSnackBar: true,
      customMessage: S.current.bag_selected_for_label_change,
    );
    Future.delayed(Durations.extralong2, () {
      if (mounted) {
        context.goNamed(ChangeBagLabelScreen.routeName);
      }
    });
  }

  List<FilterEntry> filters(
    List<BagType> selectedBagTypes, {
    required bool hasSegregation,
  }) {
    return [
      FilterEntry(
        onChanged: (value) {
          setState(() {
            showOpen = value ?? false;
          });
        },
        title: S.current.open.toUpperCase(),
        type: FilterType.bagOpen,
      ),
      FilterEntry(
        onChanged: (value) {
          setState(() {
            showClosed = value ?? false;
          });
        },
        title: S.current.sealed.toUpperCase(),
        type: FilterType.bagClosed,
      ),
      if (hasSegregation) ...[
        FilterEntry(
          onChanged: (value) {
            context.read<BagsCubit>().changeTypeFilter(
              type: BagType.plastic,
              bagStates: BagState.values,
            );
          },
          title: S.current.plastic.toUpperCase(),
          type: FilterType.bagPET,
        ),
        FilterEntry(
          onChanged: (value) {
            context.read<BagsCubit>().changeTypeFilter(
              type: BagType.can,
              bagStates: BagState.values,
            );
          },
          title: S.current.can.toUpperCase(),
          type: FilterType.bagCan,
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bagsState = context.watch<BagsCubit>().state;

    final hasSegregation = context.select<DeviceConfigCubit, bool>(
      (cubit) => cubit.state.collectionPointData?.segregatesItems ?? false,
    );
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.change_label_or_bag),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: SearchBagScannerWidget(onScanSuccess: onScan),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppDivider(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Filters(
                title: S.current.filter,
                filterEntries: filters(
                  bagsState.selectedBagTypes,
                  hasSegregation: hasSegregation,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    (bagsState.bagsToShow.isEmpty &&
                        bagsState.state == GeneralState.loaded)
                    ? NoItemsWidget(title: S.current.no_bags_to_display)
                    : Builder(
                        builder: (context) {
                          final bags = bagsState.bagsSorted;

                          switch ((showOpen, showClosed)) {
                            case (true, false):
                              bags.removeWhere(
                                (bag) => bag.state != BagState.open,
                              );
                            case (false, true):
                              bags.removeWhere(
                                (bag) => bag.state != BagState.closed,
                              );
                            default:
                              break;
                          }

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
                                return bag.state == BagState.open
                                    ? OpenBagButton(
                                        bag: bag,
                                        isSelected:
                                            bag.id == bagsState.selectedBag?.id,
                                        onPressed: () => _onPressed(bag),
                                      )
                                    : ClosedBagButton(
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
            ),
            const AppDivider(horizontalPadding: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () =>
                    context.goNamed(BagsManagementScreen.routeName),
                text: S.current.exit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
