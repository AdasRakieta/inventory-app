part of '../../../ok_mobile_boxes.dart';

class BoxManagementScreen extends StatefulWidget {
  const BoxManagementScreen({super.key});

  static const routeName = '/box_management';

  @override
  State<BoxManagementScreen> createState() => _BoxManagementScreenState();
}

class _BoxManagementScreenState extends State<BoxManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.manage_boxes),
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
                            icon: Assets.icons.add.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () {
                              context.goNamed(OpenNewBoxScreen.routeName);
                            },
                            text: S.current.open_new_box,
                          ),
                          IconTextButton(
                            fontSize: 13,
                            icon: Assets.icons.packageOpen.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () {
                              context.goNamed(ChooseOpenBoxScreen.routeName);
                            },
                            text: S.current.choose_open_box,
                          ),
                        ],
                      ),
                      const AppDivider(),
                      ButtonsColumn(
                        buttons: [
                          IconTextButton(
                            fontSize: 13,
                            icon: Assets.icons.packageOpen.image(
                              package: 'ok_mobile_common',
                              color: AppColors.yellow,
                            ),
                            onPressed: () {
                              context.goNamed(CloseBoxesScreen.routeName);
                            },
                            text: S.current.close_boxes,
                          ),
                          IconTextButton(
                            fontSize: 13,
                            icon: Assets.icons.label.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () {
                              context.goNamed(
                                BoxesToChangeLabelListScreen.routeName,
                              );
                            },
                            text: S.current.change_box_label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const AppDivider(),
              NavigationButton(
                icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                onPressed: () => context.goNamed(MainScreen.routeName),
                text: S.current.exit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
