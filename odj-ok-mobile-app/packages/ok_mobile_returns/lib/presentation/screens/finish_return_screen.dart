part of '../../ok_mobile_returns.dart';

class FinishReturnScreen extends StatelessWidget {
  const FinishReturnScreen({super.key});

  static const routeName = '/finish_return';

  @override
  Widget build(BuildContext context) {
    final voucherDisplayType =
        context
            .read<DeviceConfigCubit>()
            .state
            .contractorData
            ?.voucherDisplayType ??
        VoucherDisplayType.printable;

    String? chosenId;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.return_finish_confirmation),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: AlertCard(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.current.i_confirm_finish,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  subText: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      S.current.next_stage_edit_impossible,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ),
                  icon: Assets.icons.scroll.image(
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
                      onPressed: () => context.pop(),
                      text: S.current.back,
                    ),
                  ),
                  Flexible(
                    child: ButtonWithArrow(
                      onPressed: () async {
                        chosenId = await context
                            .read<ReturnsCubit>()
                            .closeReturn(voucherDisplayType);
                        if (context.mounted && chosenId != null) {
                          context
                              .read<BagsCubit>()
                              .clearCurrentReturnSelectedBag();
                          context.goNamed(
                            ReturnSummaryScreen.routeName,
                            pathParameters: {
                              ReturnSummaryScreen.currentReturnIdParam:
                                  chosenId!,
                            },
                          );
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
