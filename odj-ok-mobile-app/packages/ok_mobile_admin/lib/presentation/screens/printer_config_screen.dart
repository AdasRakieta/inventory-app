part of '../../ok_mobile_admin.dart';

class PrinterConfigScreen extends StatelessWidget {
  const PrinterConfigScreen({super.key, this.nextRoute});

  final String? nextRoute;

  static const routeName = '/printer_config';
  static const nextRouteParam = 'nextRoute';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(
          title: S.current.printer_config,
          blockReturnToHome: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<AdminCubit, AdminState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.selectedPrinterMacAddress != null)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      S.current.chosen_printer,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: NavigationButton(
                                            fontSize: 13,
                                            icon: Assets.icons.printer.image(
                                              package: 'ok_mobile_common',
                                              color: AppColors.green,
                                            ),
                                            text:
                                                state.selectedPrinterMacAddress,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SquareButton(
                                          onPressed: () {
                                            context
                                                .read<AdminCubit>()
                                                .removePrinter();
                                          },
                                          title: S.current.remove,
                                          icon: Assets.icons.remove.image(
                                            package: 'ok_mobile_common',
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const AppDivider(),
                                  ],
                                ),
                              PrinterScannerWidget(
                                onScanSuccess: (code) async {
                                  await context.read<AdminCubit>().addPrinter(
                                    code,
                                  );
                                  return true;
                                },
                              ),
                              if (state.selectedPrinterMacAddress == null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    S.current.no_chosen_printer,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: AppColors.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                            ],
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
                              if (context.canPop()) {
                                context.pop();
                              } else if (context
                                          .read<AdminCubit>()
                                          .state
                                          .selectedPrinterMacAddress !=
                                      null &&
                                  nextRoute != null) {
                                context.goNamed(nextRoute!);
                              } else {
                                context.goNamed(MainScreen.routeName);
                              }
                            },
                            text: context.canPop()
                                ? S.current.back
                                : S.current.exit,
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
      ),
    );
  }
}
