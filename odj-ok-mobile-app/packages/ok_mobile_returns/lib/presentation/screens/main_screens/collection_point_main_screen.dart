part of '../../../ok_mobile_returns.dart';

class CollectionPointMainScreen extends StatelessWidget {
  const CollectionPointMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final useMasterdataV2 = context
        .read<DeviceConfigCubit>()
        .state
        .remoteConfiguration
        .masterDataV2FeatureFlag;

    context.read<MasterDataCubit>().fetchMasterData(
      useMasterdataV2: useMasterdataV2,
    );

    final isPrinterReady =
        context.watch<AdminCubit>().state.selectedPrinterMacAddress != null;

    final collectedPackagingTypeEnum = context
        .read<DeviceConfigCubit>()
        .state
        .collectionPointData
        ?.collectedPackagingType;

    final isVoucherDigital = context
        .watch<DeviceConfigCubit>()
        .isDigitalVoucherFlow;

    final requirePrinterConfig = !isPrinterReady && !isVoucherDigital;

    final isReturnInProgress = context
        .watch<ReturnsCubit>()
        .state
        .openedReturn
        .id
        .isNotEmpty;

    final numberOfPackages = context
        .watch<ReturnsCubit>()
        .state
        .openedReturn
        .numberOfPackages;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ButtonsColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                buttons: [
                  if (isReturnInProgress) ...[
                    SummaryWidget(
                      numberToShow: numberOfPackages,
                      upperTitle: S.current.current_return,
                      onPressed: () {
                        context.goNamed(PackageScannerScreen.routeName);
                      },
                    ),
                    const AppDivider(),
                  ] else
                    IconTextButton(
                      fontSize: 13,
                      icon: Assets.icons.returns.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () => requirePrinterConfig
                          ? context.goNamed(
                              PrinterNotConfiguredScreen.routeName,
                              queryParameters: {
                                PrinterNotConfiguredScreen.finalRouteParam:
                                    PackageScannerScreen.routeName,
                                PrinterNotConfiguredScreen.subtitleParam:
                                    S.current.add_printer_to_start_return,
                              },
                            )
                          : context.goNamed(PackageScannerScreen.routeName),
                      text: S.current.return_deposing_packages,
                    ),

                  IconTextButton(
                    fontSize: 13,
                    icon: Assets.icons.scroll.image(
                      package: 'ok_mobile_common',
                      color: AppColors.lightGreen,
                    ),
                    onPressed: () =>
                        context.goNamed(ClosedReturnsScreen.routeName),
                    text: S.current.closed_returns,
                  ),
                ],
              ),

              if (collectedPackagingTypeEnum !=
                  CollectedPackagingTypeEnum.glassOnly) ...[
                const AppDivider(),
                ButtonsColumn(
                  buttons: [
                    IconTextButton(
                      fontSize: 13,
                      icon: Assets.icons.bags.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () {
                        context.goNamed(BagsManagementScreen.routeName);
                      },
                      text: S.current.bags,
                    ),
                    IconTextButton(
                      fontSize: 13,
                      icon: Assets.icons.pickup.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () => isPrinterReady
                          ? context.goNamed(PickupsManagementScreen.routeName)
                          : context.goNamed(
                              PrinterNotConfiguredScreen.routeName,
                              queryParameters: {
                                PrinterNotConfiguredScreen.finalRouteParam:
                                    ChooseBagTypeScreen.routeName,
                                PrinterNotConfiguredScreen.subtitleParam:
                                    S.current.add_printer_to_start_return,
                              },
                            ),
                      text: S.current.pickups,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
