part of '../../../ok_mobile_boxes.dart';

class OpenBoxSummaryScreen extends StatefulWidget {
  const OpenBoxSummaryScreen({
    required this.backRoute,
    this.buttonsBackRoute,
    this.readOnly = false,
    super.key,
  });

  static const routeName = '/open_box_summary';
  static const readOnlyParam = 'read_only';
  static const backRouteParam = 'back_route_param';

  final String backRoute;
  final String? buttonsBackRoute;
  final bool readOnly;

  @override
  State<OpenBoxSummaryScreen> createState() => _OpenBoxSummaryScreenState();
}

class _OpenBoxSummaryScreenState extends State<OpenBoxSummaryScreen> {
  @override
  void initState() {
    super.initState();
    final bagIds = context.read<BoxCubit>().getSelectedBoxBagIds();
    final bags = context.read<BagsCubit>().getClosedBagsByIds(bagIds);
    context.read<BoxCubit>().updateBagsInfo(bags);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BoxCubit, BoxState>(
        builder: (context, state) {
          return Scaffold(
            appBar: GeneralAppBar(
              title: '${S.current.box} ${state.selectedBox.label}',
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  OpenBoxCard(box: state.selectedBox),
                  const AppDivider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ClosableBagButtonList(
                        bags: state.selectedBox.bags,
                        onRemove: context.read<BoxCubit>().removeBagFromBox,
                      ),
                    ),
                  ),
                  const AppDivider(),
                  ButtonsRow(
                    buttons: [
                      Expanded(
                        child: NavigationButton(
                          icon: Assets.icons.back.image(
                            package: 'ok_mobile_common',
                          ),
                          onPressed: () {
                            context.goNamed(widget.backRoute);
                          },
                          text: S.current.exit,
                        ),
                      ),
                      if (!widget.readOnly)
                        Expanded(
                          child: IconTextButton(
                            enabled: state.selectedBox.bags.isNotEmpty,
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
                                  ConfirmBoxClosingScreen.selectedBoxIdsParam:
                                      state.selectedBox.id,
                                  ConfirmBoxClosingScreen.backRouteParam:
                                      OpenBoxSummaryScreen.routeName,
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
            ),
          );
        },
      ),
    );
  }
}
