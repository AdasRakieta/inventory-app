part of '../../../ok_mobile_boxes.dart';

class CloseBoxesScreen extends StatefulWidget {
  const CloseBoxesScreen({super.key});

  static const routeName = '/close_boxes';

  @override
  State<CloseBoxesScreen> createState() => _CloseBoxesScreenState();
}

class _CloseBoxesScreenState extends State<CloseBoxesScreen> {
  List<Box> selectedBoxes = [];
  List<Box> closeableBoxes = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<BoxCubit>().fetchOpenBoxes();
      if (mounted) {
        setState(() {
          closeableBoxes = context
              .read<BoxCubit>()
              .state
              .openBoxes
              .where((box) => box.bags.isNotEmpty)
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.close_boxes),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxScannerWidget(
                upperTitle: S.current.scan_box_label_or_pick_from_list,
                disableContinousEditing: false,
                onScanSuccess: (value) async {
                  final box = context.read<BoxCubit>().checkIfOpenBoxExists(
                    value,
                  );
                  if (box != null) {
                    setState(() {
                      selectedBoxes.add(box);
                    });
                    return true;
                  }
                  return false;
                },
              ),
              const AppDivider(),
              FiltersCheckbox.generic(
                onChanged: (isChecked) {
                  setState(() {
                    isChecked!
                        ? selectedBoxes = [...closeableBoxes]
                        : selectedBoxes.clear();
                  });
                },
                text: S.current.select_all,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: closeableBoxes.isEmpty
                    ? NoItemsWidget(title: S.current.no_boxes_to_display)
                    : SingleChildScrollView(
                        child: ButtonsColumn(
                          buttons: List.generate(closeableBoxes.length, (
                            index,
                          ) {
                            final box = closeableBoxes[index];

                            return OpenBoxButton(
                              box: box,
                              onPressed: () {
                                setState(() {
                                  if (selectedBoxes.contains(box)) {
                                    selectedBoxes.remove(box);
                                  } else {
                                    selectedBoxes.add(box);
                                  }
                                });
                              },
                            );
                          }),
                        ),
                      ),
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
                            context.goNamed(BoxManagementScreen.routeName);
                          },
                          text: S.current.back,
                        ),
                      ),
                      Expanded(
                        child: IconTextButton(
                          enabled: selectedBoxes.isNotEmpty,
                          color: AppColors.yellow,
                          textColor: AppColors.black,
                          icon: Assets.icons.package.image(
                            package: 'ok_mobile_common',
                            color: selectedBoxes.isNotEmpty
                                ? AppColors.black
                                : AppColors.lightBlack,
                          ),
                          onPressed: () {
                            if (selectedBoxes.length == 1) {
                              context.read<BoxCubit>().selectBox(
                                selectedBoxes.first,
                              );
                            }
                            final boxIds = selectedBoxes
                                .map((box) => box.id)
                                .join(',');
                            context.goNamed(
                              ConfirmBoxClosingScreen.routeName,
                              pathParameters: {
                                ConfirmBoxClosingScreen.selectedBoxIdsParam:
                                    boxIds,
                                ConfirmBoxClosingScreen.backRouteParam:
                                    CloseBoxesScreen.routeName,
                              },
                            );
                          },
                          text: S.current.close_boxes,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
