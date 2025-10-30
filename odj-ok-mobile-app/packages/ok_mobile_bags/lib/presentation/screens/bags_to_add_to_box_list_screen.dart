part of '../../ok_mobile_bags.dart';

class BagsToAddToBoxListScreen extends StatefulWidget {
  const BagsToAddToBoxListScreen({super.key});

  static const routeName = '/add_bag_to_box_list';

  @override
  State<BagsToAddToBoxListScreen> createState() =>
      _BagsToAddToBoxListScreenState();
}

class _BagsToAddToBoxListScreenState extends State<BagsToAddToBoxListScreen> {
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
      }
    });
  }

  List<Widget> _notChosenBags(List<Bag> bags, List<Bag> bagsToAddToBox) {
    final notChosenBagButtons = <Widget>[];
    for (final bag in bags) {
      if (bagsToAddToBox.contains(bag)) {
        continue;
      }
      notChosenBagButtons.add(
        ClosedBagButton(
          bag: bag,
          isSelected: bagsToAddToBox.contains(bag),
          onPressed: () {
            context.read<BagsCubit>().addBagToBoxList([bag]);
          },
        ),
      );
    }
    return notChosenBagButtons;
  }

  @override
  Widget build(BuildContext context) {
    final bagsState = context.watch<BagsCubit>().state;
    final selectedBags = bagsState.bagsToShow
        .where((bag) => bag.boxId == null && bag.seal != null)
        .toList();

    final bagsToAddToBox = bagsState.bagsToAddToBox;

    final segregation = context.select<DeviceConfigCubit, bool>(
      (cubit) => cubit.state.collectionPointData?.segregatesItems ?? false,
    );

    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.closed_bags),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SealScannerWidget(
                title: S.current.scan_bag_seal_code,
                onScanSuccess: (sealLabel) async {
                  final bag = context
                      .read<BagsCubit>()
                      .checkIfClosedBagExistsBySeal(sealLabel);
                  if (bag != null) {
                    context.read<BagsCubit>().addBagToBoxList([bag]);
                    return true;
                  }
                  return false;
                },
              ),
              const AppDivider(),
              if (segregation) ...[
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
                const AppDivider(),
              ],
              FiltersCheckbox(
                onChanged: (isChecked) {
                  setState(() {
                    isChecked!
                        ? context.read<BagsCubit>().addBagToBoxList(
                            selectedBags,
                          )
                        : context.read<BagsCubit>().clearBagsToAddToBox();
                  });
                },
                text: S.current.select_all,
                activeBackgroundColor: AppColors.darkGreen,
                uncheckedBorderColor: AppColors.green,
                initialValue: false,
              ),
              const SizedBox(height: 16),
              if (selectedBags.isEmpty &&
                  bagsState.generalState == GeneralState.loaded)
                Expanded(child: NoItemsWidget(title: S.current.no_closed_bags))
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (bagsToAddToBox.isNotEmpty) ...[
                          ButtonsColumn(
                            buttons: List.generate(bagsToAddToBox.length, (
                              index,
                            ) {
                              final bag = bagsToAddToBox[index];
                              return ClosedBagButton(
                                bag: bag,
                                isSelected: bagsToAddToBox.contains(bag),
                                onPressed: () {
                                  context
                                      .read<BagsCubit>()
                                      .removeBagFromBoxList(bag);
                                },
                              );
                            }),
                          ),
                          const AppDivider(height: 16),
                        ],
                        ButtonsColumn(
                          buttons: _notChosenBags(selectedBags, bagsToAddToBox),
                        ),
                      ],
                    ),
                  ),
                ),
              const AppDivider(verticalPadding: 0),
              ButtonsRow(
                buttons: [
                  Expanded(
                    child: NavigationButton(
                      icon: Assets.icons.back.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () =>
                          context.goNamed(BagsManagementScreen.routeName),
                      text: S.current.back,
                    ),
                  ),
                  // Expanded(
                  //   child: IconTextButton(
                  //     enabled: bagsToAddToBox.isNotEmpty,
                  //     icon: Assets.icons.packagePlus.image(
                  //       package: 'ok_mobile_common',
                  //       color: bagsToAddToBox.isNotEmpty
                  //           ? AppColors.black
                  //           : AppColors.lightBlack,
                  //     ),
                  //     color: AppColors.yellow,
                  //     onPressed: () {
                  //       context.read<BagsCubit>().selectBags(bagsToAddToBox);
                  //       context.goNamed(
                  //         ChooseBoxScreen.routeName,
                  //         queryParameters: {
                  //           ChooseBoxScreen.singleBagModeParam: 'false',
                  //         },
                  //       );
                  //     },
                  //     text: S.current.add_to_box,
                  //     textColor: AppColors.black,
                  //     fontSize: 11,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
