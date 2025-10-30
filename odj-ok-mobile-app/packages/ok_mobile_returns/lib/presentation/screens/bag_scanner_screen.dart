part of '../../ok_mobile_returns.dart';

class BagScannerScreen extends StatelessWidget {
  const BagScannerScreen({
    required this.type,
    this.clearLastPackage = false,
    super.key,
  });

  final BagType type;
  final bool clearLastPackage;

  static const routeName = '/bag_scanner';
  static const typeParam = 'type';

  @override
  Widget build(BuildContext context) {
    final hasSegregation = context.select<DeviceConfigCubit, bool>(
      (cubit) => cubit.state.collectionPointData?.segregatesItems ?? false,
    );
    return SafeArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: GeneralAppBar(
              title:
                  '${S.current.open_new_bag}${hasSegregation ? ': '
                            '${type.localisedName}' : ''}',
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
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
                                BagScannerWidget(
                                  type: type,
                                  onScanSuccess: (value) async {
                                    final wasBagOpened = await context
                                        .read<BagsCubit>()
                                        .openNewBag(
                                          bagType: type,
                                          bagLabel: value,
                                          collectionPointId: context
                                              .read<DeviceConfigCubit>()
                                              .state
                                              .collectionPointData!
                                              .id,
                                        );
                                    if (wasBagOpened && context.mounted) {
                                      context
                                          .read<ReturnsCubit>()
                                          .assignMostRecentPackageToBag(
                                            context
                                                .read<BagsCubit>()
                                                .state
                                                .currentReturnSelectedBag!,
                                          );
                                      context.goNamed(
                                        PackageScannerScreen.routeName,
                                      );
                                    }
                                    return wasBagOpened;
                                  },
                                ),
                                Column(
                                  children: [
                                    const AppDivider(),
                                    NavigationButton(
                                      icon: Assets.icons.back.image(
                                        package: 'ok_mobile_common',
                                      ),
                                      onPressed: () {
                                        context.goNamed(
                                          ChooseBagTypeScreen.routeName,
                                          queryParameters: {
                                            ChooseBagTypeScreen.bagTypeParam:
                                                type.name,
                                            ChooseBagTypeScreen
                                                    .clearLastPackageParam:
                                                clearLastPackage.toString(),
                                          },
                                        );
                                      },
                                      text: S.current.back,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
