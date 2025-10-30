part of '../../ok_mobile_boxes.dart';

class BoxesToChangeLabelListScreen extends StatefulWidget {
  const BoxesToChangeLabelListScreen({super.key});

  static const routeName = '/change_label_boxes_list';

  @override
  State<BoxesToChangeLabelListScreen> createState() =>
      _BoxesToChangeLabelListScreenState();
}

class _BoxesToChangeLabelListScreenState
    extends State<BoxesToChangeLabelListScreen> {
  bool showOpen = false;
  bool showClosed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<BoxCubit>().fetchOpenBoxes(),
        context.read<BoxCubit>().fetchClosedBoxes(),
        context.read<BagsCubit>().fetchClosedBags(),
      ]);
    });
  }

  Future<bool> onScan(String value) async {
    final boxFound = context.read<BoxCubit>().selectBoxByLabel(value);
    if (boxFound) {
      context.goNamed(ChangeBoxLabelScreen.routeName);
      return true;
    }

    return false;
  }

  bool get statusFiltersEnabled {
    return showOpen || showClosed;
  }

  List<FilterEntry> filters() {
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
        title: S.current.closed.toUpperCase(),
        type: FilterType.bagClosed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final boxesState = context.watch<BoxCubit>().state;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.change_label),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
              child: BaseScannerWidget(
                onScanSuccess: onScan,
                upperTitle: S.current.scan_box_label_or_pick_from_list,
                lowerTitle: '${S.current.or_enter_box_number}:',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppDivider(verticalPadding: 8),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Filters(title: S.current.filter, filterEntries: filters()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: boxesState.allBoxes.isEmpty
                    ? NoItemsWidget(title: S.current.no_boxes_to_display)
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            OpenBoxButtonsColumn(
                              openBoxes: showOpen || !statusFiltersEnabled
                                  ? boxesState.openBoxes
                                  : [],
                              onPressed: (box) {
                                context.read<BoxCubit>().selectBox(
                                  box,
                                  showSnackBar: false,
                                );
                                context.goNamed(ChangeBoxLabelScreen.routeName);
                              },
                            ),
                            if (showClosed == showOpen)
                              const AppDivider(verticalPadding: 4),
                            ClosedBoxButtonsColumn(
                              closedBoxes: showClosed || !statusFiltersEnabled
                                  ? boxesState.closedBoxes
                                  : [],
                              onPressed: (box) {
                                context.read<BoxCubit>().selectBox(
                                  box,
                                  showSnackBar: false,
                                );
                                context.goNamed(ChangeBoxLabelScreen.routeName);
                              },
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const AppDivider(verticalPadding: 0),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () => context.goNamed(BoxManagementScreen.routeName),
                text: S.current.back,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
