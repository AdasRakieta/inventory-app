part of '../../ok_mobile_counting_center.dart';

class CCPackageReceivalScreen extends StatefulWidget {
  const CCPackageReceivalScreen({super.key});

  static const String routeName = '/cc_package_receival_screen';

  @override
  State<CCPackageReceivalScreen> createState() =>
      _CCPackageReceivalScreenState();
}

class _CCPackageReceivalScreenState extends State<CCPackageReceivalScreen> {
  late final String countingCenterId;
  @override
  void initState() {
    super.initState();
    context.read<ReceivalsCubit>().startNewReceival();
    countingCenterId =
        context.read<DeviceConfigCubit>().state.contractorData!.id;
  }

  @override
  Widget build(BuildContext context) {
    final openedReturn = context.watch<ReturnsCubit>().state.openedReturn;
    return SafeArea(
      child: BlocBuilder<ReceivalsCubit, ReceivalsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: GeneralAppBar(title: S.current.package_receival),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SimpleSummaryWidget(
                                title: S.current.current_receival,
                                quantity:
                                    state.currentReceival?.bags?.length ?? 0,
                              ),
                              const SizedBox(height: 8),
                              CCSealScannerWidget(
                                title:
                                    S.current.scan_seal_and_add_bag_to_receival,
                                onScanSuccess: (value) async {
                                  final bag = await context
                                      .read<ReceivalsCubit>()
                                      .validateBag(value, countingCenterId);

                                  if (bag != null && context.mounted) {
                                    context
                                        .read<ReceivalsCubit>()
                                        .addBagToReceival(bag);
                                  }

                                  return bag != null;
                                },
                              ),
                              const SizedBox(height: 12),
                              switch ([
                                state.currentReceival,
                                state.currentReceival?.bags,
                              ]) {
                                [Pickup _, []] => Column(
                                  children: [
                                    Text(
                                      style: AppTextStyle.pItalic(),
                                      S.current.no_received_bags,
                                    ),
                                  ],
                                ),
                                [Pickup _, final List<Bag> values]
                                    when values.isNotEmpty =>
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.current.list_of_added_bags,
                                        style: AppTextStyle.smallBold(),
                                      ),
                                      const SizedBox(height: 8),
                                      ClosedButtonsColumn(
                                        closedBags: values,
                                        selectedBag: null,
                                        openedReturn: openedReturn,
                                      ),
                                    ],
                                  ),
                                _ => const SizedBox.shrink(),
                              },
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
                                        context.goNamed(MainScreen.routeName);
                                      },
                                      text: S.current.exit,
                                    ),
                                  ),
                                  Expanded(
                                    child: IconTextButton(
                                      enabled:
                                          state.currentReceival != null &&
                                          state
                                              .currentReceival!
                                              .bags!
                                              .isNotEmpty,
                                      color: AppColors.yellow,
                                      textColor: AppColors.black,
                                      icon: Assets.icons.clipboard.image(
                                        package: 'ok_mobile_common',
                                        color:
                                            state.currentReceival != null &&
                                                    state
                                                        .currentReceival!
                                                        .bags!
                                                        .isNotEmpty
                                                ? AppColors.black
                                                : AppColors.lightBlack,
                                      ),
                                      onPressed: () async {
                                        final confirmed = await context
                                            .read<ReceivalsCubit>()
                                            .confirmReceival(countingCenterId);
                                        if (context.mounted && confirmed) {
                                          context.goNamed(
                                            CCCollectedReceivalsScreen
                                                .routeName,
                                          );
                                        }
                                      },
                                      text: S.current.confirm_receival,
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
