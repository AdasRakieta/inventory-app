part of '../../../ok_mobile_boxes.dart';

class OpenNewBoxScreen extends StatelessWidget {
  const OpenNewBoxScreen({super.key});

  static const routeName = '/open_new_box';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<BoxCubit, BoxState>(
        listener: (context, state) {
          if (state.result is Success) {
            context.goNamed(AddBagsScreen.routeName);
          }
        },
        child: Scaffold(
          appBar: GeneralAppBar(title: S.current.open_new_box),
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
                              BoxScannerWidget(
                                onScanSuccess: (value) async {
                                  return context.read<BoxCubit>().openNewBox(
                                    value,
                                  );
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
                                        BoxManagementScreen.routeName,
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
        ),
      ),
    );
  }
}
