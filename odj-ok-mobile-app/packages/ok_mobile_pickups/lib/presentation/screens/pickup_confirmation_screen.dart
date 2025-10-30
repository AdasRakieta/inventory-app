part of '../../../ok_mobile_pickups.dart';

class PickupConfirmationScreen extends StatelessWidget {
  const PickupConfirmationScreen({super.key});

  static const routeName = '/pickup_confirmation';

  @override
  Widget build(BuildContext context) {
    final macAddress = context
        .read<AdminCubit>()
        .state
        .selectedPrinterMacAddress;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.handing_over_driver),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: AlertCard(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          S.current.i_confirm_pickup,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          S.current.pickup_confirmation_subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.lightGreen,
                              ),
                        ),
                      ],
                    ),
                  ),
                  icon: Assets.icons.pickup.image(
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
                        final navigate =
                            await context
                                .read<PickupsCubit>()
                                .confirmPickupAndPrintDocument(macAddress!) !=
                            null;
                        if (context.mounted && navigate) {
                          context.goNamed(PickupsListScreen.routeName);
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
