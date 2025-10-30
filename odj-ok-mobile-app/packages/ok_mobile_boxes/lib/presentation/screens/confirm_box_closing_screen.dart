part of '../../../ok_mobile_boxes.dart';

class ConfirmBoxClosingScreen extends StatelessWidget {
  const ConfirmBoxClosingScreen({
    required this.selectedBoxIds,
    required this.backRoute,
    super.key,
  });

  static const routeName = '/confirm_box_closing';
  static const selectedBoxIdsParam = 'selected_box_ids';
  static const backRouteParam = 'back_route_param';

  final List<String> selectedBoxIds;
  final String backRoute;

  @override
  Widget build(BuildContext context) {
    final isSingleBoxSelected = selectedBoxIds.length == 1;
    final selectedBox = isSingleBoxSelected
        ? context.read<BoxCubit>().state.selectedBox
        : null;

    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(
          title: isSingleBoxSelected
              ? '${S.current.box} ${selectedBox!.label}'
              : S.current.close_boxes,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: AlertCard(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: S.current.do_you_really_want_to_close,
                        style: Theme.of(context).textTheme.labelLarge,
                        children: isSingleBoxSelected
                            ? [
                                TextSpan(
                                  text: ' ${S.current.of_a_box}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                TextSpan(
                                  text: ' ${selectedBox!.label}?',
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ]
                            : [
                                TextSpan(
                                  text: ' ${S.current.of_all_boxes}',
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                      ),
                    ),
                  ),
                  icon: Assets.icons.package.image(
                    package: 'ok_mobile_common',
                    color: AppColors.lightGreen,
                    height: 40,
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
                      onPressed: () => context.goNamed(backRoute),
                      text: S.current.back,
                    ),
                  ),
                  Flexible(
                    child: ButtonWithArrow(
                      onPressed: () async {
                        final navigate = await context
                            .read<BoxCubit>()
                            .closeBoxes(selectedBoxIds);

                        if (navigate && context.mounted) {
                          if (isSingleBoxSelected) {
                            context.goNamed(ClosedBoxSummaryScreen.routeName);
                          } else {
                            context.goNamed(BoxManagementScreen.routeName);
                          }
                        }
                      },
                      title: S.current.i_confirm,
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
