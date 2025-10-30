part of '../../ok_mobile_bags.dart';

class BagsManagementScreen extends StatefulWidget {
  const BagsManagementScreen({super.key});

  static const routeName = '/bags_management';

  @override
  State<BagsManagementScreen> createState() => _BagsManagementScreenState();
}

class _BagsManagementScreenState extends State<BagsManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.bags),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ButtonsColumn(
                        buttons: [
                          IconTextButton(
                            fontSize: 13,
                            icon: Assets.icons.bagClosed.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () {
                              context.goNamed(
                                BagsToCloseAndAddSealListScreen.routeName,
                              );
                            },
                            text: S.current.seal_bag,
                          ),
                        ],
                      ),
                      const AppDivider(),
                      ButtonsColumn(
                        buttons: [
                          IconTextButton(
                            fontSize: 13,
                            icon: Assets.icons.label.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () {
                              context.goNamed(
                                BagsToChangeLabelListScreen.routeName,
                              );
                            },
                            text: S.current.change_label_or_bag,
                          ),
                          IconTextButton(
                            fontSize: 13,
                            icon: Assets.icons.sealChange.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () {
                              context.goNamed(
                                BagsToChangeSealListScreen.routeName,
                              );
                            },
                            text: S.current.change_seal,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      onPressed: () => context.goNamed(MainScreen.routeName),
                      text: S.current.exit,
                    ),
                  ),
                  Flexible(
                    child: NavigationButton(
                      icon: Assets.icons.bagClosed.image(
                        package: 'ok_mobile_common',
                        color: AppColors.green,
                      ),
                      onPressed: () =>
                          context.goNamed(ClosedBagsListScreen.routeName),
                      text: S.current.sealed_bags_list,
                      horizontalPadding: 8,
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
