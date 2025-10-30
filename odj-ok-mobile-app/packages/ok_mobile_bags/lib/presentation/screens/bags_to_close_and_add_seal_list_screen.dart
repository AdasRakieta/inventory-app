part of '../../ok_mobile_bags.dart';

class BagsToCloseAndAddSealListScreen extends StatefulWidget {
  const BagsToCloseAndAddSealListScreen({super.key});

  static const routeName = '/add_bag_seal_list';

  @override
  State<BagsToCloseAndAddSealListScreen> createState() =>
      _BagsToCloseAndAddSealListScreenState();
}

class _BagsToCloseAndAddSealListScreenState
    extends State<BagsToCloseAndAddSealListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<BagsCubit>().fetchOpenBags();
      if (mounted) {
        context.read<BagsCubit>().clearSelectedBag();
        context.read<BagsCubit>().getBagsAndSaveToState(
          selectedStates: [BagState.open],
          selectedTypes: [],
        );
      }
    });
  }

  Future<bool> _onScan(String value) async {
    final openedReturn = context.read<ReturnsCubit>().state.openedReturn;
    final bag = context.read<BagsCubit>().getBagByLabel(
      value,
      onlyOpenBags: true,
      successMessage: S.current.bag_selected_for_closing,
      currentlyOpenedReturn: openedReturn,
    );

    if (bag != null) {
      await Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          final consolidatedPackages =
              ReturnsHelper.aggregatePackagesFromLocalAndRemote(
                bag: bag,
                localReturnPackages: openedReturn.packages,
              );
          if (consolidatedPackages.isNotEmpty) {
            context.goNamed(CloseAndSealBagScreen.routeName);
          }
        }
      });

      return true;
    }

    return false;
  }

  Future<void> _onPressed(String label) async {
    context.read<BagsCubit>().getBagByLabel(
      label,
      successMessage: S.current.bag_selected_for_closing,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.goNamed(CloseAndSealBagScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bagsState = context.watch<BagsCubit>().state;
    final openedReturn = context.read<ReturnsCubit>().state.openedReturn;
    final selectedBags = bagsState.bagsToShow
        .where(
          (bag) =>
              bag.seal == null &&
              ReturnsHelper.aggregatePackagesFromLocalAndRemote(
                bag: bag,
                localReturnPackages: openedReturn.packages,
              ).isNotEmpty,
        )
        .toList();

    final hasSegregation = context.select<DeviceConfigCubit, bool>(
      (cubit) => cubit.state.collectionPointData?.segregatesItems ?? false,
    );
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.seal_bag),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChooseBagScannerWidget(onScanSuccess: _onScan),
              if (hasSegregation) ...[
                const SizedBox(height: 4),
                const AppDivider(verticalPadding: 4),
                PackageTypeFilters(
                  selectedBagTypes: bagsState.selectedBagTypes,
                  onPetFilterChanged: (value) {
                    context.read<BagsCubit>().changeTypeFilter(
                      type: BagType.plastic,
                      bagStates: [BagState.open],
                    );
                  },
                  onCanFilterChanged: (value) {
                    context.read<BagsCubit>().changeTypeFilter(
                      type: BagType.can,
                      bagStates: [BagState.open],
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),

              Expanded(
                child:
                    selectedBags.isEmpty &&
                        bagsState.generalState == GeneralState.loaded
                    ? const NoItemsWidget()
                    : OpenBagSegmentedButtonsColumn(
                        bags: selectedBags,
                        openedReturn: openedReturn,
                        onPressed: _onPressed,
                        selectedBagId: bagsState.selectedBag?.id,
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
