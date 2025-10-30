part of '../../ok_mobile_bags.dart';

class ClosedBagDetailsScreen extends StatelessWidget {
  const ClosedBagDetailsScreen({
    required this.selectedBagId,
    this.hideManagementOptions = false,
    this.bagsList,
    super.key,
  });
  static const routeName = '/closed_bag_details';
  static const hideManagementOptionsParam = 'hide_management_options';
  static const selectedBagIdParam = 'selected_bag_id_param';

  final bool hideManagementOptions;
  final String selectedBagId;
  final List<Bag>? bagsList;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BagsCubit, BagsState>(
        builder: (context, state) {
          final bags = bagsList ?? state.closedBags;
          final selectedBag = bags.firstWhere((bag) => bag.id == selectedBagId);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClosedBagButton(bag: selectedBag),
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

                  NavigationButton(
                    icon: Assets.icons.back.image(
                      package: 'ok_mobile_common',
                      height: 16,
                    ),
                    text: context.canPop() ? S.current.back : S.current.exit,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.goNamed(ClosedBagsListScreen.routeName),
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
