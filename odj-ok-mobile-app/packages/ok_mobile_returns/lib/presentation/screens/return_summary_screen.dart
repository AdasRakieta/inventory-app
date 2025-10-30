part of '../../ok_mobile_returns.dart';

class ReturnSummaryScreen extends StatefulWidget {
  const ReturnSummaryScreen({
    required this.selectedReturnId,
    this.freshClose = false,
    this.showBackButton = false,
    this.backToClosed = true,
    this.allowVoucherReprint = false,
    super.key,
  });

  static const routeName = '/return_summary';
  static const currentReturnIdParam = 'selected_return_id';
  static const showBackButtonParam = 'show_back_button';

  final String selectedReturnId;
  final bool freshClose;
  final bool showBackButton;
  final bool backToClosed;
  final bool allowVoucherReprint;

  @override
  State<ReturnSummaryScreen> createState() => _ReturnSummaryScreenState();
}

class _ReturnSummaryScreenState extends State<ReturnSummaryScreen> {
  final List<ActionReason> cancellationReasons = [
    ActionReason.clientResignation,
    ActionReason.technicalIssue,
    ActionReason.differentIssue,
  ];

  ActionReason? selectedCancellationReason;

  final List<ActionReason> reprintReasons = [
    ActionReason.illegibleVoucher,
    ActionReason.lostVoucher,
    ActionReason.differentReason,
  ];

  ActionReason? selectedReprintReason;

  final List<ActionReason> printReasons = [
    ActionReason.errorOnFirstPrint,
    ActionReason.voucherIssuance,
    ActionReason.incorrectlyRejected,
    ActionReason.differentReason,
  ];

  late bool allowReprint;
  late VoucherDisplayType? voucherDisplayType;

  @override
  void initState() {
    super.initState();
    allowReprint = widget.allowVoucherReprint;
    voucherDisplayType = context
        .read<DeviceConfigCubit>()
        .state
        .contractorData
        ?.voucherDisplayType;
  }

  @override
  Widget build(BuildContext context) {
    final backRoute = widget.backToClosed
        ? ClosedReturnsScreen.routeName
        : ReturnsArchiveScreen.routeName;
    final showDigitalVoucher = context
        .read<DeviceConfigCubit>()
        .isDigitalVoucherFlow;

    return SafeArea(
      child: BlocBuilder<ReturnsCubit, ReturnsState>(
        builder: (context, state) {
          final selectedReturn =
              state.returns.firstWhereOrNull(
                (element) => element.id == widget.selectedReturnId,
              ) ??
              Return.empty();
          return Scaffold(
            appBar: GeneralAppBar(
              title: '${S.current.return_text} ${selectedReturn.code}',
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildContent(selectedReturn, showDigitalVoucher),
                            ],
                          ),
                        ),
                      ),
                      _buildBottomButtons(
                        selectedReturn,
                        backRoute,
                        showDigitalVoucher,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(Return selectedReturn, bool showDigitalVoucher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.current.return_summary, style: AppTextStyle.smallBold()),
        const SizedBox(height: 8),
        PackagesSummaryList(
          returnElement: selectedReturn,
          upperTitle: selectedReturn.code ?? '',
          closeDate: selectedReturn.closedTime ?? DateTime.now(),
          voucherDisplayType: voucherDisplayType,
        ),
        const SizedBox(height: 12),
        ...switch ((showDigitalVoucher, selectedReturn.state, allowReprint)) {
          (true, _, _) => [const SizedBox.shrink()],
          (_, ReturnState.canceled, _) => [
            _buildCancellationReasonBox(
              selectedReturn.voucherCancellationReason?.label ?? '',
            ),
            if (allowReprint) ...[
              const AppDivider(),
              _buildDropdownSection(
                title: S.current.choose_voucher_print_reason,
                reasons: printReasons,
                selected: selectedReprintReason,
                onChanged: (value) => setState(() {
                  selectedReprintReason = value;
                }),
              ),
            ],
          ],

          (_, ReturnState.printed, true) => [
            _buildDropdownSection(
              title: S.current.choose_voucher_reprint_reason,
              reasons: reprintReasons,
              selected: selectedReprintReason,
              onChanged: (value) => setState(() {
                selectedReprintReason = value;
              }),
            ),
          ],

          (_, ReturnState.unfinished || ReturnState.ongoing, _) => [
            _buildDropdownSection(
              title: S.current.reason_for_voucher_print_cancelation,
              reasons: cancellationReasons,
              selected: selectedCancellationReason,
              onChanged: (value) => setState(() {
                selectedCancellationReason = value;
              }),
              onReset: () => setState(() {
                selectedCancellationReason = null;
              }),
            ),
          ],

          _ => [],
        },
      ],
    );
  }

  Widget _buildCancellationReasonBox(String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkGrey),
      ),
      child: Text(label, style: AppTextStyle.p()),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required List<ActionReason> reasons,
    required ActionReason? selected,
    required void Function(ActionReason?) onChanged,
    VoidCallback? onReset,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.smallItalic()),
        const SizedBox(height: 8),
        OkDropdownButton(
          reasons: reasons,
          value: selected,
          onChanged: onChanged,
          onReset: onReset,
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
    Return selectedReturn,
    String backRoute,
    bool showDigitalVoucher,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDivider(),
        switch ((
          showDigitalVoucher,
          selectedReturn.state,
          allowReprint,
          selectedReprintReason,
          selectedCancellationReason,
        )) {
          (true, _, true, _, _) => ButtonsRow(
            buttons: [
              Expanded(
                child: NavigationButton(
                  icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(backRoute);
                    }
                  },
                  text: S.current.back,
                ),
              ),
              Expanded(
                child: NavigationButton(
                  icon: Assets.icons.scroll.image(
                    package: 'ok_mobile_common',
                    color: AppColors.green,
                  ),
                  onPressed: () => context.pushNamed(
                    VoucherDisplayScreen.routeName,
                    pathParameters: {
                      VoucherDisplayScreen.selectedReturnIdParam:
                          selectedReturn.id,
                    },
                  ),
                  text: S.current.show_voucher,
                ),
              ),
            ],
          ),
          (true, _, false, _, _) => IconTextButton(
            icon: Assets.icons.printer.image(package: 'ok_mobile_common'),
            onPressed: () => context.pushNamed(
              VoucherDisplayScreen.routeName,
              pathParameters: {
                VoucherDisplayScreen.selectedReturnIdParam: selectedReturn.id,
              },
              queryParameters: {
                VoucherDisplayScreen.isFirstTimeDisplayedParam: 'true',
              },
            ),
            text: S.current.show_voucher,
            color: AppColors.yellow,
            textColor: AppColors.black,
          ),
          (_, final state, true, _, _)
              when ![
                ReturnState.unfinished,
                ReturnState.ongoing,
              ].contains(state) =>
            ButtonsRow(
              buttons: [
                Expanded(
                  child: NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(backRoute);
                      }
                    },
                    text: S.current.back,
                  ),
                ),
                Expanded(
                  child: IconTextButton(
                    enabled: selectedReprintReason != null,
                    icon: Assets.icons.printer.image(
                      package: 'ok_mobile_common',
                      color: selectedReprintReason != null
                          ? AppColors.black
                          : AppColors.lightBlack,
                    ),
                    color: AppColors.yellow,
                    textColor: AppColors.black,
                    onPressed: () => printVoucher(
                      context
                          .read<AdminCubit>()
                          .state
                          .selectedPrinterMacAddress,
                      selectedReturn,
                      reprintReason: selectedReprintReason,
                    ),
                    text: S.current.print_voucher,
                  ),
                ),
              ],
            ),

          (_, ReturnState.printed || ReturnState.canceled, _, _, _) =>
            ButtonsRow(
              buttons: [
                Expanded(
                  child: NavigationButton(
                    icon: Assets.icons.returns.image(
                      package: 'ok_mobile_common',
                      color: AppColors.green,
                    ),
                    onPressed: () =>
                        context.goNamed(PackageScannerScreen.routeName),
                    text: S.current.packages_return,
                  ),
                ),
                Expanded(
                  child: NavigationButton(
                    icon: Assets.icons.scroll.image(
                      package: 'ok_mobile_common',
                      color: AppColors.green,
                    ),
                    onPressed: () =>
                        context.goNamed(ClosedReturnsScreen.routeName),
                    text: S.current.closed_returns,
                  ),
                ),
              ],
            ),

          (_, _, _, _, final ActionReason reason) => NavigationButton(
            icon: Assets.icons.printerCrossed.image(
              package: 'ok_mobile_common',
              color: AppColors.green,
            ),
            onPressed: () async {
              await context.read<ReturnsCubit>().cancelVoucherPrint(
                selectedReturn,
                reason: reason,
              );
              setState(() {
                selectedCancellationReason = null;
                allowReprint = false;
              });
            },
            text: S.current.cancel_voucher_print,
          ),

          (_, final state, _, _, _) when state != ReturnState.printed =>
            ButtonsRow(
              buttons: [
                if (widget.showBackButton)
                  Expanded(
                    child: NavigationButton(
                      icon: Assets.icons.back.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed(backRoute);
                        }
                      },
                      text: S.current.back,
                    ),
                  ),
                Expanded(
                  child: IconTextButton(
                    icon: Assets.icons.printer.image(
                      package: 'ok_mobile_common',
                    ),
                    onPressed: () => printVoucher(
                      context
                          .read<AdminCubit>()
                          .state
                          .selectedPrinterMacAddress,
                      selectedReturn,
                    ),
                    text: S.current.print_voucher,
                    color: AppColors.yellow,
                    textColor: AppColors.black,
                  ),
                ),
              ],
            ),

          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  Future<void> printVoucher(
    String? macAddress,
    Return selectedReturn, {
    ActionReason? reprintReason,
  }) async {
    final printerAvailable = await context.read<ReturnsCubit>().checkPrinter(
      macAddress,
    );

    if (printerAvailable && mounted) {
      final navigate = await context.read<ReturnsCubit>().printVoucher(
        voucherId: selectedReturn.voucher!.id,
        voucherCode: selectedReturn.voucher!.code,
        depositValue: selectedReturn.voucher!.depositValue ?? 0.0,
        returnCode: selectedReturn.code!,
        packages: ReturnsHelper.aggregatePackagesFromDifferentBags(
          selectedReturn.packages
              .map(
                (element) => element.copyWith(
                  description:
                      element.description ??
                      context.read<MasterDataCubit>().getPackageDescription(
                        element.eanCode,
                      ) ??
                      '',
                  type: context.read<MasterDataCubit>().getPackageType(
                    element.eanCode,
                  ),
                ),
              )
              .toList(),
        ),
        macAddress: macAddress!,
        collectionPoint: context
            .read<DeviceConfigCubit>()
            .state
            .collectionPointData!,
        contractorData: context.read<DeviceConfigCubit>().state.contractorData!,
        reprintReason: reprintReason,
      );
      if (mounted && navigate) {
        widget.backToClosed
            ? context.goNamed(
                ConfirmVoucherPrintScreen.routeName,
                pathParameters: {
                  ConfirmVoucherPrintScreen.currentReturnIdParam:
                      selectedReturn.id,
                },
              )
            : context.goNamed(
                ArchiveConfirmVoucherPrintScreen.routeName,
                pathParameters: {
                  ArchiveConfirmVoucherPrintScreen.currentReturnIdParam:
                      selectedReturn.id,
                },
              );
      }
    }
  }
}
