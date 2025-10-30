part of '../../ok_mobile_bags.dart';

class OpenBagDetailsScreen extends StatelessWidget {
  const OpenBagDetailsScreen({
    required this.showCloseBagButton,
    required this.selectedBagId,
    this.openedFromReturns = false,
    super.key,
  });

  static const routeName = '/open_bag_details';
  static const closeBagParam = 'close_bag_param';
  static const selectedBagIdParam = 'selected_bag_id_param';
  static const openedFromReturnsParam = 'opened_from_returns_param';

  final String selectedBagId;
  final bool showCloseBagButton;
  final bool openedFromReturns;

  @override
  Widget build(BuildContext context) {
    final openedReturn = context.watch<ReturnsCubit>().state.openedReturn;
    final selectedBag = context.read<BagsCubit>().state.openBags.firstWhere(
      (element) => element.id == selectedBagId,
    );
    final consolidatedPackages =
        ReturnsHelper.aggregatePackagesFromLocalAndRemote(
          bag: selectedBag,
          localReturnPackages: openedReturn.packages,
        );
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.bag_summary),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              OpenBagButton(bag: selectedBag),
              const AppDivider(),
              Expanded(
                child: (consolidatedPackages.isEmpty)
                    ? NoItemsWidget(title: S.current.no_packages_in_open_bag)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.current.packages_in_bag,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: List.generate(
                                consolidatedPackages.length,
                                (index) {
                                  final package = consolidatedPackages[index];
                                  return PackageInfoCard(
                                    title:
                                        context
                                            .read<MasterDataCubit>()
                                            .getPackageDescription(
                                              package.eanCode,
                                            ) ??
                                        '',
                                    ean: package.eanCode,
                                    numberOfPackages: package.quantity,
                                    backgroundColor:
                                        BagsHelper.resolveBackgroundColor(
                                          package.type ??
                                              context
                                                  .read<MasterDataCubit>()
                                                  .getPackageType(
                                                    package.eanCode,
                                                  ),
                                        ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const AppDivider(),
              ButtonsRow(
                buttons: [
                  Flexible(
                    child: NavigationButton(
                      icon: Assets.icons.back.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () {
                        context.canPop()
                            ? context.pop()
                            : context.goNamed(
                                openedFromReturns
                                    ? PackageScannerScreen.routeName
                                    : BagsManagementScreen.routeName,
                              );
                      },
                      text: context.canPop() ? S.current.back : S.current.exit,
                    ),
                  ),
                  if (showCloseBagButton)
                    Flexible(
                      child: IconTextButton(
                        icon: Assets.icons.bagClosed.image(
                          package: 'ok_mobile_common',
                          color: consolidatedPackages.isNotEmpty
                              ? AppColors.black
                              : AppColors.lightBlack,
                        ),
                        enabled: consolidatedPackages.isNotEmpty,
                        color: AppColors.yellow,
                        onPressed: () {
                          context.read<BagsCubit>().getBagByLabel(
                            selectedBag.label,
                            successMessage: S.current.bag_selected_for_closing,
                          );

                          context.goNamed(
                            CloseAndSealBagScreen.routeName,
                            queryParameters: {
                              CloseAndSealBagScreen.openedFromReturnsParam:
                                  openedFromReturns.toString(),
                            },
                          );
                        },
                        text: S.current.seal_bag,
                        textColor: AppColors.black,
                      ),
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
