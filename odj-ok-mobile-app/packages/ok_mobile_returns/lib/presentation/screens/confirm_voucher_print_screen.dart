part of '../../ok_mobile_returns.dart';

class ConfirmVoucherPrintScreen extends StatelessWidget {
  const ConfirmVoucherPrintScreen({
    required this.selectedReturnId,
    this.backToClosed = true,
    super.key,
  });

  static const routeName = '/confirm_voucher_print';
  static const currentReturnIdParam = 'selected_return_id';

  final String selectedReturnId;
  final bool backToClosed;

  @override
  Widget build(BuildContext context) {
    final selectedReturn = context
        .read<ReturnsCubit>()
        .state
        .returns
        .firstWhere((element) => element.id == selectedReturnId);

    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(
          title: '${S.current.return_text} ${selectedReturn.code}',
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
                        text: S.current.confirm_voucher_print,
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: ' ${selectedReturn.code}',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  icon: Assets.icons.printer.image(
                    package: 'ok_mobile_common',
                    color: AppColors.lightGreen,
                    height: 40,
                  ),
                ),
              ),
              const AppDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ButtonsRow(
                  buttons: [
                    Flexible(
                      child: NavigationButton(
                        icon: Assets.icons.remove.image(
                          package: 'ok_mobile_common',
                          color: AppColors.green,
                        ),
                        onPressed: () => backToClosed
                            ? context.goNamed(
                                ClosedReturnSummaryScreen.routeName,
                                pathParameters: {
                                  ClosedReturnSummaryScreen
                                          .currentReturnIdParam:
                                      selectedReturn.id,
                                  ClosedReturnSummaryScreen
                                          .shouldShowBackButtonParam:
                                      'false',
                                },
                              )
                            : context.goNamed(
                                ArchiveClosedReturnSummaryScreen.routeName,
                                pathParameters: {
                                  ArchiveClosedReturnSummaryScreen
                                          .currentReturnIdParam:
                                      selectedReturn.id,
                                },
                              ),
                        text: S.current.reject,
                      ),
                    ),
                    Flexible(
                      child: ButtonWithArrow(
                        title: S.current.i_confirm,
                        onPressed: () async {
                          final navigate = await context
                              .read<ReturnsCubit>()
                              .confirmVoucherPrint(
                                selectedReturn,
                                isReprint:
                                    selectedReturn.state == ReturnState.printed,
                              );

                          if (navigate && context.mounted) {
                            context.goNamed(
                              SuccessReturnSummaryScreen.routeName,
                              pathParameters: {
                                SuccessReturnSummaryScreen.currentReturnIdParam:
                                    selectedReturn.id,
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
