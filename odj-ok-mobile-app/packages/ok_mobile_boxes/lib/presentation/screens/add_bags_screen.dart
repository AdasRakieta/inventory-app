part of '../../../ok_mobile_boxes.dart';

class AddBagsScreen extends StatefulWidget {
  const AddBagsScreen({super.key});

  static const routeName = '/add_bags';

  @override
  State<AddBagsScreen> createState() => _AddBagsScreenState();
}

class _AddBagsScreenState extends State<AddBagsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
    await context.read<BagsCubit>().fetchClosedBags();

    if (mounted) {
      final bagIds = context.read<BoxCubit>().getSelectedBoxBagIds();
      final bags = context.read<BagsCubit>().getClosedBagsByIds(bagIds);
      context.read<BoxCubit>().updateBagsInfo(bags);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bagsState = context.watch<BagsCubit>().state;

    return SafeArea(
      child: BlocBuilder<BoxCubit, BoxState>(
        builder: (context, state) {
          return Scaffold(
            appBar: GeneralAppBar(
              title: '${S.current.box} ${state.selectedBox.label}',
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SummaryWidget(
                                numberToShow: state.selectedBox.bags.length,
                                title: S.current.box_summary,
                                enabled: state.selectedBox.bags.isNotEmpty,
                                onPressed: () {
                                  context.goNamed(
                                    AddBagsOpenBoxSummaryScreen.routeName,
                                  );
                                },
                                fontSize: 11,
                              ),
                              const SizedBox(height: 8),
                              SealScannerWidget(
                                title: S.current.scan_bag_seal_code,
                                onScanSuccess: (value) async {
                                  final bag = context
                                      .read<BagsCubit>()
                                      .checkIfClosedBagExistsBySeal(value);
                                  if (bag != null && context.mounted) {
                                    await context.read<BoxCubit>().addBagsToBox(
                                      bags: [bag],
                                    );
                                    return true;
                                  }
                                  return false;
                                },
                              ),
                              if (state.selectedBox.bags.isNotEmpty &&
                                  bagsState.state == GeneralState.loaded) ...[
                                const AppDivider(),
                                ClosableBagButtonList(
                                  bags: state.selectedBox.bags,
                                  onRemove: context
                                      .read<BoxCubit>()
                                      .removeBagFromBox,
                                ),
                              ],
                            ],
                          ),
                          Column(
                            children: [
                              const AppDivider(),
                              ButtonsRow(
                                buttons: [
                                  Expanded(
                                    child: NavigationButton(
                                      icon: Assets.icons.back.image(
                                        package: 'ok_mobile_common',
                                      ),
                                      onPressed: () {
                                        context.goNamed(
                                          BoxManagementScreen.routeName,
                                        );
                                      },
                                      text: S.current.exit,
                                    ),
                                  ),
                                  Expanded(
                                    child: IconTextButton(
                                      enabled:
                                          state.selectedBox.bags.isNotEmpty,
                                      color: AppColors.yellow,
                                      textColor: AppColors.black,
                                      icon: Assets.icons.package.image(
                                        package: 'ok_mobile_common',
                                        color: state.selectedBox.bags.isNotEmpty
                                            ? null
                                            : AppColors.lightBlack,
                                      ),
                                      onPressed: () {
                                        context.goNamed(
                                          ConfirmBoxClosingScreen.routeName,
                                          pathParameters: {
                                            ConfirmBoxClosingScreen
                                                    .selectedBoxIdsParam:
                                                state.selectedBox.id,
                                            ConfirmBoxClosingScreen
                                                    .backRouteParam:
                                                AddBagsScreen.routeName,
                                          },
                                        );
                                      },
                                      text: S.current.close_box,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
