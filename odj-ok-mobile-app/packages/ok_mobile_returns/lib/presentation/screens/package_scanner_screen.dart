part of '../../ok_mobile_returns.dart';

class PackageScannerScreen extends StatefulWidget {
  const PackageScannerScreen({super.key});

  static const routeName = '/package_scanner';

  @override
  State<PackageScannerScreen> createState() => _PackageScannerScreenState();
}

class _PackageScannerScreenState extends State<PackageScannerScreen> {
  @override
  void initState() {
    super.initState();
    final returnsState = context.read<ReturnsCubit>().state;
    if (returnsState.openedReturn.id.isEmpty) {
      context.read<ReturnsCubit>().createNewReturn();
    }
    final currentBag = context.read<BagsCubit>().state.currentReturnSelectedBag;
    if (currentBag?.state == BagState.closed) {
      context.read<BagsCubit>().clearCurrentReturnSelectedBag();
    }

    context.read<ReturnsCubit>().clearMostRecentPackage(
      customMessage: S.current.last_package_not_assigned_and_removed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final returnsState = context.watch<ReturnsCubit>().state;
    final openedReturn = returnsState.openedReturn;
    final bagsState = context.watch<BagsCubit>().state;
    final currentBag = bagsState.currentReturnSelectedBag;
    final isGlassOnly =
        context
            .read<DeviceConfigCubit>()
            .state
            .collectionPointData
            ?.collectedPackagingType ==
        CollectedPackagingTypeEnum.glassOnly;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(
          title: isGlassOnly
              ? S.current.glass_return
              : S.current.return_deposing_packages,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentBag != null)
                        ..._buildPickedBagButton(
                          selectedBag: currentBag,
                          openedReturn: openedReturn,
                        ),
                      SimpleSummaryWidget(
                        title: S.current.current_return,
                        quantity: openedReturn.numberOfPackages,
                      ),

                      const SizedBox(height: 12),
                      PackageScannerWidget(selectedBag: currentBag),
                      const SizedBox(height: 6),
                      if (returnsState.openedReturn.packages.isEmpty)
                        NoItemsWidget(title: S.current.no_packeges_in_return)
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              isGlassOnly
                                  ? S.current.returning_packages_list
                                  : S.current.actual_return_full_packages_list,
                              style: AppTextStyle.smallBold(),
                            ),
                            const SizedBox(height: 12),
                            ButtonsColumn(
                              buttons: List.generate(
                                openedReturn.packages.length,
                                (index) {
                                  final package = openedReturn.packages[index];
                                  final bag = context
                                      .read<BagsCubit>()
                                      .state
                                      .allBags
                                      .firstWhereOrNull(
                                        (element) =>
                                            element.id == package.bagId,
                                      );

                                  final isEditEnabled =
                                      bag == null ||
                                      bag.state == BagState.open ||
                                      (package.type?.isGlass() ?? false);

                                  return PackageDetailsCard(
                                    isLabelOrSealVisible:
                                        package.type?.isGlass() == false &&
                                        bag != null,
                                    bagIdentifier:
                                        (isEditEnabled
                                            ? bag?.label
                                            : bag.seal) ??
                                        '',
                                    description: package.description ?? '',
                                    quantity: package.quantity,
                                    ean: package.eanCode,
                                    backgroundColor:
                                        BagsHelper.resolveBackgroundColor(
                                          package.type,
                                        ),
                                    enableEdit: isEditEnabled,
                                    onDecrease: () => context
                                        .read<ReturnsCubit>()
                                        .decreasePackageQuantity(
                                          package.eanCode,
                                          package.bagId,
                                        ),
                                    onRemove: () => context
                                        .read<ReturnsCubit>()
                                        .removePackage(
                                          package.eanCode,
                                          package.bagId,
                                        ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    const AppDivider(),
                    _buildBottomButtons(
                      openedReturn: openedReturn,
                      selectedBag: currentBag,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPickedBagButton({
    required Bag selectedBag,
    required Return openedReturn,
  }) => switch (selectedBag.type) {
    BagType.glass => const [SizedBox.shrink()],
    _ => [
      Text(
        '${S.current.chosen_bag_for_packages}: '
        '${selectedBag.type.localisedName}',
        style: AppTextStyle.smallBold(),
      ),
      const SizedBox(height: 8),
      OpenBagButton(
        onPressed: () {
          context.pushNamed(
            OpenBagDetailsScreen.routeName,
            pathParameters: {
              OpenBagDetailsScreen.closeBagParam: 'true',
              OpenBagDetailsScreen.selectedBagIdParam: selectedBag.id!,
            },
            queryParameters: {
              OpenBagDetailsScreen.openedFromReturnsParam: 'true',
            },
          );
        },
        bag: selectedBag,
      ),
      const AppDivider(),
    ],
  };

  Widget _buildBottomButtons({
    required Return openedReturn,
    required Bag? selectedBag,
  }) {
    return switch (openedReturn) {
      final Return opened when opened.isReadyToClose => ButtonsRow(
        buttons: [
          if (selectedBag != null) _buildChangeBagButton(),
          _buildFinishButton(),
        ],
      ),
      _ => _buildRejectButton(),
    };
  }

  Widget _buildRejectButton() {
    return NavigationButton(
      icon: Assets.icons.exit.image(
        package: 'ok_mobile_common',
        color: AppColors.green,
      ),
      onPressed: () {
        context.read<ReturnsCubit>().rejectReturn();
        context.read<BagsCubit>().clearCurrentReturnSelectedBag();
        context.goNamed(MainScreen.routeName);
      },
      text: S.current.reject_return,
    );
  }

  Widget _buildChangeBagButton() {
    return Flexible(
      child: NavigationButton(
        icon: Assets.icons.edit.image(
          package: 'ok_mobile_common',
          color: AppColors.green,
        ),
        onPressed: () {
          context.goNamed(
            ChooseBagTypeScreen.routeName,
            queryParameters: {
              ChooseBagTypeScreen.clearLastPackageParam: 'false',
            },
          );
        },
        text: S.current.change_bag,
      ),
    );
  }

  Widget _buildFinishButton() {
    return Flexible(
      child: IconTextButton(
        icon: Assets.icons.scroll.image(
          package: 'ok_mobile_common',
          color: AppColors.black,
        ),
        onPressed: () {
          context.read<ReturnsCubit>().clearMostRecentPackage();
          context.pushNamed(FinishReturnScreen.routeName);
        },
        text: S.current.finish_return,
        color: AppColors.yellow,
        textColor: Colors.black,
      ),
    );
  }
}
