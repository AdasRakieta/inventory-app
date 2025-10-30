part of '../../ok_mobile_bags.dart';

class CloseAndSealBagScreen extends StatelessWidget {
  const CloseAndSealBagScreen({this.openedFromReturns = false, super.key});

  final bool openedFromReturns;

  static const routeName = '/add_bag_seal';
  static const openedFromReturnsParam = 'opened_from_returns_param';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BagsCubit, BagsState>(
        builder: (context, state) {
          final selectedBag = state.selectedBag;

          return Scaffold(
            appBar: GeneralAppBar(title: S.current.seal_bag),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    S.current.chosen_bag,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: AppColors.black,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OpenBagButton(
                    bag: selectedBag!,
                    onPressed: () {
                      context.pushNamed(
                        OpenBagDetailsScreen.routeName,
                        pathParameters: {
                          OpenBagDetailsScreen.closeBagParam: 'false',
                          OpenBagDetailsScreen.selectedBagIdParam:
                              selectedBag.id!,
                        },
                        queryParameters: {
                          OpenBagDetailsScreen.openedFromReturnsParam:
                              openedFromReturns.toString(),
                        },
                      );
                    },
                  ),
                  const AppDivider(),
                  SealScannerWidget(
                    title: S.current.scan_seal,
                    onScanSuccess: (seal) async {
                      final navigate = await context
                          .read<BagsCubit>()
                          .closeAndSealBag(selectedBag.id!, seal: seal);

                      if (navigate && context.mounted) {
                        await context.pushNamed(
                          SealAddedDetailsScreen.routeName,
                          queryParameters: {
                            SealAddedDetailsScreen.openedFromReturnsParam:
                                openedFromReturns.toString(),
                            SealAddedDetailsScreen
                                    .showCloseAnotherBagButtonParam:
                                'true',
                          },
                        );
                        return true;
                      }
                      return false;
                    },
                    type: selectedBag.type,
                  ),
                  const Spacer(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () {
                      openedFromReturns
                          ? context.goNamed(
                              OpenBagDetailsScreen.routeName,
                              pathParameters: {
                                OpenBagDetailsScreen.closeBagParam: 'true',
                                OpenBagDetailsScreen.selectedBagIdParam:
                                    selectedBag.id!,
                              },
                              queryParameters: {
                                OpenBagDetailsScreen.openedFromReturnsParam:
                                    'true',
                              },
                            )
                          : context.goNamed(
                              BagsToCloseAndAddSealListScreen.routeName,
                            );
                    },
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
