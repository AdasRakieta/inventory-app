part of '../../../ok_mobile_boxes.dart';

class ClosedBoxSummaryScreen extends StatefulWidget {
  const ClosedBoxSummaryScreen({
    required this.backRoute,
    this.buttonsBackRoute,
    this.readOnly = false,
    super.key,
  });

  static const routeName = '/closed_box_summary';
  static const readOnlyParam = 'read_only';
  static const backRouteParam = 'back_route_param';

  final String backRoute;
  final String? buttonsBackRoute;
  final bool readOnly;

  @override
  State<ClosedBoxSummaryScreen> createState() => _ClosedBoxSummaryScreenState();
}

class _ClosedBoxSummaryScreenState extends State<ClosedBoxSummaryScreen> {
  @override
  void initState() {
    super.initState();
    final bagIds = context.read<BoxCubit>().getSelectedBoxBagIds();
    final bags = context.read<BagsCubit>().getClosedBagsByIds(bagIds);
    context.read<BoxCubit>().updateBagsInfo(bags);
  }

  @override
  Widget build(BuildContext context) {
    final openedReturn = context.watch<ReturnsCubit>().state.openedReturn;
    return SafeArea(
      child: BlocBuilder<BoxCubit, BoxState>(
        builder: (context, state) {
          final selectedBox = state.selectedBox;

          return Scaffold(
            appBar: GeneralAppBar(
              title: '${S.current.box} ${selectedBox.label}',
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClosedBoxCard(box: selectedBox),
                  const AppDivider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ClosedButtonsColumn(
                        closedBags: selectedBox.bags,
                        selectedBag: null,
                        openedReturn: openedReturn,
                        onPressed: (bag) {
                          context.read<BagsCubit>().getBagByLabel(
                            bag.label,
                            successMessage: S.current.bag_correctly_chosen,
                          );
                          context.pushNamed(
                            ClosedBagDetailsScreen.routeName,
                            queryParameters: {
                              ClosedBagDetailsScreen.hideManagementOptionsParam:
                                  'true',
                            },
                            pathParameters: {
                              ClosedBagDetailsScreen.selectedBagIdParam:
                                  bag.id!,
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const AppDivider(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () {
                      context.goNamed(widget.backRoute);
                    },
                    text: S.current.exit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
