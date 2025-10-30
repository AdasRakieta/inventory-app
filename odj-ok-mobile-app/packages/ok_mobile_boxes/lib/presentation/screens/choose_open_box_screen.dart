part of '../../../ok_mobile_boxes.dart';

class ChooseOpenBoxScreen extends StatelessWidget {
  const ChooseOpenBoxScreen({super.key});

  static const routeName = '/choose_open_box';

  Future<void> _prepareData(BuildContext context) async {
    context.read<BoxCubit>().clearSelectedBox();
    await Future.wait([
      context.read<BoxCubit>().fetchOpenBoxes(),
      context.read<BagsCubit>().fetchClosedBags(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _prepareData(context);
    return SafeArea(
      child: BlocConsumer<BoxCubit, BoxState>(
        listener: (context, state) {
          if (state.result is Success) {
            Future.delayed(Durations.extralong2, () {
              if (context.mounted) {
                context.goNamed(AddBagsScreen.routeName);
              }
            });
          }
        },
        builder: (context, state) => Scaffold(
          appBar: GeneralAppBar(title: S.current.choose_open_box),
          body: IgnorePointer(
            ignoring: !state.selectedBox.isEmpty,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BoxScannerWidget(
                    upperTitle: S.current.scan_box_label_or_pick_from_list,
                    onScanSuccess: (value) async {
                      return context.read<BoxCubit>().selectBoxByLabel(value);
                    },
                  ),
                  const AppDivider(),
                  Expanded(
                    child:
                        state.openBoxes.isEmpty &&
                            state.generalState == GeneralState.loaded
                        ? NoItemsWidget(title: S.current.no_boxes_to_display)
                        : SingleChildScrollView(
                            child: ButtonsColumn(
                              buttons: List.generate(state.openBoxes.length, (
                                index,
                              ) {
                                final box = state.openBoxes[index];

                                return OpenBoxButton(
                                  box: box,
                                  onPressed: () {
                                    context.read<BoxCubit>().selectBox(
                                      box,
                                      showSnackBar: false,
                                    );
                                    context.goNamed(
                                      OpenBoxSummaryScreen.routeName,
                                      queryParameters: {
                                        OpenBoxSummaryScreen.backRouteParam:
                                            ChooseOpenBoxScreen.routeName,
                                      },
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                  ),
                  Column(
                    children: [
                      const AppDivider(),
                      NavigationButton(
                        icon: Assets.icons.back.image(
                          package: 'ok_mobile_common',
                        ),
                        onPressed: () {
                          context.goNamed(BoxManagementScreen.routeName);
                        },
                        text: S.current.back,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
