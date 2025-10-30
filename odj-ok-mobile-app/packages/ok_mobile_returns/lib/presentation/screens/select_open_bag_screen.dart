part of '../../ok_mobile_returns.dart';

class SelectOpenBagScreen extends StatefulWidget {
  const SelectOpenBagScreen({
    required this.type,
    this.clearLastPackage = true,
    this.backRoute = '',
    super.key,
  });

  final BagType type;

  static const routeName = '/open_bags';
  static const typeParam = 'type_param';
  static const backRouteParam = 'back_route';

  final String backRoute;
  final bool clearLastPackage;

  @override
  State<SelectOpenBagScreen> createState() => _SelectOpenBagScreenState();
}

class _SelectOpenBagScreenState extends State<SelectOpenBagScreen> {
  Bag? previousBag;

  @override
  void initState() {
    super.initState();
    final currentBag = context.read<BagsCubit>().state.currentReturnSelectedBag;
    if (currentBag != null) previousBag = currentBag;
    context.read<BagsCubit>().clearCurrentReturnSelectedBag();
    _fetchBags();
  }

  Future<void> _fetchBags() async {
    await context.read<BagsCubit>().fetchOpenBags();
  }

  Future<bool> _onBagSelected(String label) async {
    final selectedBag = context
        .read<BagsCubit>()
        .setCurrentReturnSelectedBagByLabel(label);
    if (selectedBag != null) {
      context.read<ReturnsCubit>().assignMostRecentPackageToBag(selectedBag);
      Future.delayed(Durations.extralong2, () {
        if (mounted) {
          context.goNamed(PackageScannerScreen.routeName);
        }
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final returnsState = context.watch<ReturnsCubit>().state;
    final bagsState = context.watch<BagsCubit>().state;
    final bagsToShow = bagsState.openBags
        .where((bag) => bag.type == widget.type)
        .toList();
    final hasSegregation = context.select<DeviceConfigCubit, bool>(
      (cubit) => cubit.state.collectionPointData?.segregatesItems ?? false,
    );
    return SafeArea(
      child: IgnorePointer(
        ignoring: bagsState.selectedBag != null,
        child: Scaffold(
          appBar: GeneralAppBar(
            title:
                '${S.current.open_bags_list}${hasSegregation ? ': '
                          '${widget.type.localisedName}' : ''}',
            onLeadingPressed: () {
              if (previousBag != null) {
                context.read<BagsCubit>().selectBag(bag: previousBag!);
              }
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChooseBagScannerWidget(onScanSuccess: _onBagSelected),
                const SizedBox(height: 8),
                Expanded(
                  child: (bagsState.generalState == GeneralState.loading)
                      ? const SizedBox.shrink()
                      : bagsToShow.isEmpty
                      ? NoItemsWidget(
                          title: S.current.no_open_bags_of_this_type,
                        )
                      : OpenBagSegmentedButtonsColumn(
                          bags: bagsToShow,
                          openedReturn: returnsState.openedReturn,
                          onPressed: _onBagSelected,
                          selectedBagId: bagsState.currentReturnSelectedBag?.id,
                        ),
                ),
                const AppDivider(),
                NavigationButton(
                  icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                  onPressed: () {
                    if (previousBag != null) {
                      context.read<BagsCubit>().selectBag(bag: previousBag!);
                    }
                    context.goNamed(
                      ChooseBagTypeScreen.routeName,
                      queryParameters: {
                        ChooseBagTypeScreen.bagTypeParam: widget.type.name,
                        ChooseBagTypeScreen.clearLastPackageParam: widget
                            .clearLastPackage
                            .toString(),
                      },
                    );
                  },
                  text: S.current.back,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
