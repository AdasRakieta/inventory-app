part of '../../ok_mobile_boxes.dart';

class ChangeBoxLabelScreen extends StatefulWidget {
  const ChangeBoxLabelScreen({super.key});

  static const routeName = '/change_box_label';

  @override
  State<ChangeBoxLabelScreen> createState() => _ChangeBoxLabelScreenState();
}

class _ChangeBoxLabelScreenState extends State<ChangeBoxLabelScreen> {
  final List<ActionReason> _reasons = [
    ActionReason.damagedLabel,
    ActionReason.unreadableLabel,
    ActionReason.tornBox,
  ];

  ActionReason? selectedValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BoxCubit, BoxState>(
        builder: (context, state) {
          final selectedBox = state.selectedBox;

          return Scaffold(
            appBar: GeneralAppBar(title: S.current.change_label),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (selectedBox.isOpen)
                    OpenBoxButton(
                      box: selectedBox,
                      onPressed: () {
                        context.goNamed(
                          ChangeLabelOpenBoxSummaryScreen.routeName,
                        );
                      },
                      icon: Assets.icons.next.image(
                        color: AppColors.black,
                        package: 'ok_mobile_common',
                        height: 16,
                      ),
                    )
                  else
                    ClosedBoxButton(
                      box: selectedBox,
                      onPressed: () {
                        context.goNamed(
                          ChangeLabelClosedBoxSummaryScreen.routeName,
                        );
                      },
                      icon: Assets.icons.next.image(
                        color: AppColors.black,
                        package: 'ok_mobile_common',
                        height: 16,
                      ),
                    ),
                  const SizedBox(height: 12),
                  OkDropdownButton(
                    hint: S.current.choose_reason_for_label_change,
                    reasons: _reasons,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                    value: selectedValue,
                  ),
                  const SizedBox(height: 12),
                  if (selectedValue != null)
                    BoxScannerWidget(
                      onScanSuccess: (newLabel) async {
                        final navigate = await context
                            .read<BoxCubit>()
                            .updateBoxLabel(
                              selectedBox.id,
                              newLabel: newLabel,
                              reason: selectedValue!,
                            );

                        if (navigate && context.mounted) {
                          (selectedBox.isOpen)
                              ? context.goNamed(
                                  OpenBoxSummaryScreen.routeName,
                                  queryParameters: {
                                    OpenBoxSummaryScreen.backRouteParam:
                                        BoxesToChangeLabelListScreen.routeName,
                                  },
                                )
                              : context.goNamed(
                                  ClosedBoxSummaryScreen.routeName,
                                  queryParameters: {
                                    ClosedBoxSummaryScreen.backRouteParam:
                                        BoxesToChangeLabelListScreen.routeName,
                                  },
                                );
                          return true;
                        }
                        return false;
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  const Spacer(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () =>
                        context.goNamed(BoxesToChangeLabelListScreen.routeName),
                    text: S.current.back,
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
