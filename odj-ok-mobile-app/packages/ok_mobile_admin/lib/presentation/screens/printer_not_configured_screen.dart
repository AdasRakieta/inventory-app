part of '../../ok_mobile_admin.dart';

class PrinterNotConfiguredScreen extends StatelessWidget {
  const PrinterNotConfiguredScreen({
    required this.finalRoute,
    required this.subtitle,
    super.key,
  });

  final String finalRoute;
  final String subtitle;

  static const routeName = '/printer_not_configured';
  static const finalRouteParam = 'finalRoute';
  static const subtitleParam = 'subtitle';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.return_deposing_packages),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: AlertCard(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.current.configure_printer,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  subText: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.lightGreen,
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
                        icon: Assets.icons.back.image(
                          package: 'ok_mobile_common',
                        ),
                        onPressed: () => context.goNamed(MainScreen.routeName),
                        text: S.current.back,
                      ),
                    ),
                    Flexible(
                      child: IconTextButton(
                        icon: Assets.icons.printer.image(
                          package: 'ok_mobile_common',
                        ),
                        text: S.current.printer_config,
                        textColor: AppColors.black,
                        onPressed: () {
                          context.goNamed(
                            PrinterConfigScreen.routeName,
                            queryParameters: {
                              PrinterConfigScreen.nextRouteParam: finalRoute,
                            },
                          );
                        },
                        color: AppColors.yellow,
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
