part of '../../ok_mobile_bags.dart';

class ChangeBagLabelScreen extends StatefulWidget {
  const ChangeBagLabelScreen({super.key});

  static const routeName = '/change_bag_label';
  static final labelFieldKey = GlobalKey<DoubleScannerCodeTextFieldState>();
  static final sealFieldKey = GlobalKey<DoubleScannerCodeTextFieldState>();

  @override
  State<ChangeBagLabelScreen> createState() => _ChangeBagLabelScreenState();
}

class _ChangeBagLabelScreenState extends State<ChangeBagLabelScreen> {
  String? newLabel;
  String? newSeal;

  late TextEditingController labelEditingController;
  late TextEditingController sealEditingController;

  final List<ActionReason> _reasons = [
    ActionReason.unreadableLabel,
    ActionReason.damagedLabel,
    ActionReason.tornBag,
  ];

  ActionReason? selectedValue;

  @override
  void initState() {
    super.initState();
    labelEditingController = TextEditingController();
    sealEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBag = context.read<BagsCubit>().state.selectedBag!;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.change_label_or_bag),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.current.chosen_bag,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium!.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      if (selectedBag.state == BagState.closed)
                        ClosedBagButton(
                          bag: selectedBag,
                          onPressed: () {
                            context.pushNamed(
                              ClosedBagDetailsScreen.routeName,
                              queryParameters: {
                                ClosedBagDetailsScreen
                                        .hideManagementOptionsParam:
                                    'true',
                              },
                              pathParameters: {
                                ClosedBagDetailsScreen.selectedBagIdParam:
                                    selectedBag.id!,
                              },
                            );
                          },
                        )
                      else
                        OpenBagButton(
                          bag: selectedBag,
                          onPressed: () {
                            context.pushNamed(
                              OpenBagDetailsScreen.routeName,
                              pathParameters: {
                                OpenBagDetailsScreen.closeBagParam: 'false',
                                OpenBagDetailsScreen.selectedBagIdParam:
                                    selectedBag.id!,
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 12),
                      OkDropdownButton(
                        hint: S.current.choose_reason_for_label_or_bag_change,
                        reasons: _reasons,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                            if (selectedValue == ActionReason.tornBag &&
                                selectedBag.seal != null) {
                              context.read<BagsCubit>().issueWarning(
                                S.current.change_seal_after_label_change,
                              );
                            }
                          });
                        },
                        value: selectedValue,
                      ),
                      if (selectedValue != null) const AppDivider(),
                      if (selectedValue == ActionReason.tornBag &&
                          selectedBag.seal != null)
                        DoubleScannerWidget(
                          labelTextInputController: labelEditingController,
                          sealTextInputController: sealEditingController,
                          onScanFirstSuccess: (newLabel) {
                            setState(() {
                              this.newLabel = newLabel;
                              context.read<BagsCubit>().showConfirmation(
                                S.current.label_scan_success,
                              );
                            });
                          },
                          onManualInputFirst: (newLabel) {
                            setState(() {
                              this.newLabel = newLabel;
                            });
                          },
                          onClearFirst: () {
                            setState(() {
                              newLabel = null;
                            });
                          },
                          onScanSecondSuccess: (newSeal) {
                            setState(() {
                              this.newSeal = newSeal;
                              context.read<BagsCubit>().showConfirmation(
                                S.current.seal_scan_success,
                              );
                            });
                          },
                          onClearSecond: () {
                            setState(() {
                              newSeal = null;
                            });
                          },
                          onManualInputSecond: (newSeal) {
                            setState(() {
                              this.newSeal = newSeal;
                            });
                          },
                          upperTitle: S.current.scan_new_bag_label_code,
                          upperTitle2: S.current.scan_new_seal_code,
                          upperWarning: S.current.make_sure_codes_are_correct,
                          lowerTitle1: S.current.or_enter_label_number,
                          lowerTitle2: S.current.or_enter_seal_number,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        )
                      else if (selectedValue != null)
                        BagScannerWidget(
                          title: S.current.scan_new_bag_label_code,
                          subtitle: S.current.or_enter_label_number,
                          onScanSuccess: (newLabel) async {
                            final navigate = await context
                                .read<BagsCubit>()
                                .updateBagLabel(
                                  selectedBag.id!,
                                  newLabel: newLabel,
                                  reason: selectedValue!,
                                );

                            if (navigate && context.mounted) {
                              (selectedBag.state == BagState.closed)
                                  ? context.goNamed(
                                      ClosedBagDetailsScreen.routeName,
                                      pathParameters: {
                                        ClosedBagDetailsScreen
                                                .selectedBagIdParam:
                                            selectedBag.id!,
                                      },
                                    )
                                  : context.goNamed(
                                      OpenBagDetailsScreen.routeName,
                                      pathParameters: {
                                        OpenBagDetailsScreen.closeBagParam:
                                            'true',
                                        OpenBagDetailsScreen.selectedBagIdParam:
                                            selectedBag.id!,
                                      },
                                    );
                              return true;
                            }

                            return false;
                          },
                          type: selectedBag.type,
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              const AppDivider(),
              if (newLabel != null && newSeal != null)
                ButtonsRow(
                  buttons: [
                    Expanded(
                      child: NavigationButton(
                        icon: Assets.icons.remove.image(
                          package: 'ok_mobile_common',
                          color: AppColors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            ChangeBagLabelScreen.sealFieldKey.currentState
                                ?.clearInput();
                            ChangeBagLabelScreen.labelFieldKey.currentState
                                ?.clearInput();
                            newLabel = null;
                            newSeal = null;
                          });
                        },
                        text: S.current.reject,
                      ),
                    ),
                    Expanded(
                      child: ButtonWithArrow(
                        onPressed: () async {
                          final navigate = await context
                              .read<BagsCubit>()
                              .updateBag(
                                selectedBag.id!,
                                newLabel: newLabel!,
                                newSeal: newSeal!,
                                reason: selectedValue!,
                              );

                          if (navigate && context.mounted) {
                            context.goNamed(
                              ClosedBagDetailsScreen.routeName,
                              queryParameters: {
                                ClosedBagDetailsScreen
                                        .hideManagementOptionsParam:
                                    'false',
                              },
                              pathParameters: {
                                ClosedBagDetailsScreen.selectedBagIdParam:
                                    selectedBag.id!,
                              },
                            );
                          }
                        },
                        title: S.current.i_confirm,
                      ),
                    ),
                  ],
                )
              else
                NavigationButton(
                  icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                  onPressed: () =>
                      context.goNamed(BagsToChangeLabelListScreen.routeName),
                  text: S.current.back,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
