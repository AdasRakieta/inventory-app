part of '../../ok_mobile_bags.dart';

class SealAddedDetailsScreen extends StatelessWidget {
  const SealAddedDetailsScreen({
    this.openedFromReturns = false,
    this.showCloseAnotherBagButton = false,
    super.key,
  });
  static const routeName = '/seal_added_details';
  static const openedFromReturnsParam = 'opened_from_returns_param';
  static const showCloseAnotherBagButtonParam =
      'show_close_another_bag_button_param';

  final bool openedFromReturns;
  final bool showCloseAnotherBagButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BagsCubit, BagsState>(
        builder: (context, state) {
          final selectedBag = state.selectedBag;
          final openedReturn = context.watch<ReturnsCubit>().state.openedReturn;
          final consolidatedPackages =
              ReturnsHelper.aggregatePackagesFromLocalAndRemote(
                bag: selectedBag,
                localReturnPackages: openedReturn.packages,
              );
          return Scaffold(
            appBar: GeneralAppBar(title: S.current.bag_summary),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClosedBagButton(bag: selectedBag!),

                  const AppDivider(),
                  Text(
                    S.current.packages_in_bag,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: List.generate(consolidatedPackages.length, (
                        index,
                      ) {
                        final package = consolidatedPackages[index];
                        return PackageInfoCard(
                          title:
                              context
                                  .read<MasterDataCubit>()
                                  .getPackageDescription(package.eanCode) ??
                              '',
                          ean: package.eanCode,
                          numberOfPackages: package.quantity,
                          backgroundColor: BagsHelper.resolveBackgroundColor(
                            package.type ??
                                context.read<MasterDataCubit>().getPackageType(
                                  package.eanCode,
                                ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const AppDivider(),
                  ButtonsRow(
                    buttons: [
                      Expanded(
                        child: openedFromReturns
                            ? NavigationButton(
                                icon: Assets.icons.returns.image(
                                  package: 'ok_mobile_common',
                                  height: 16,
                                  color: AppColors.green,
                                ),
                                text: S.current.packages_return,
                                onPressed: () {
                                  context.goNamed(
                                    PackageScannerScreen.routeName,
                                  );
                                },
                              )
                            : NavigationButton(
                                icon: Assets.icons.back.image(
                                  package: 'ok_mobile_common',
                                  height: 16,
                                ),
                                text: S.current.exit,
                                onPressed: () {
                                  context.goNamed(
                                    BagsManagementScreen.routeName,
                                  );
                                },
                              ),
                      ),
                      if (showCloseAnotherBagButton)
                        Expanded(
                          child: NavigationButton(
                            icon: Assets.icons.bagClosed.image(
                              package: 'ok_mobile_common',
                              height: 16,
                              color: AppColors.green,
                            ),
                            text: S.current.seal_another_bag,
                            onPressed: () {
                              context.goNamed(
                                BagsToCloseAndAddSealListScreen.routeName,
                              );
                            },
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
