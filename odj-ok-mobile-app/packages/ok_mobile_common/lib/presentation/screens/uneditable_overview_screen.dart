part of '../../ok_mobile_common.dart';

class UneditableOverviewScreen extends StatelessWidget {
  const UneditableOverviewScreen({
    required this.title,

    required this.onPressed,
    required this.selectedPickup,
    this.summaryTitle,

    super.key,
  });

  final String title;

  final void Function(Bag) onPressed;
  final String? summaryTitle;
  final Pickup selectedPickup;

  @override
  Widget build(BuildContext context) {
    final openedReturn = context.watch<ReturnsCubit>().state.openedReturn;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: title),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PickupButton(
                title: selectedPickup.code!,
                date: selectedPickup.dateAdded,
                pickupStatus: selectedPickup.status!,
                onPressed: () {},
                withSplashEffect: false,
                amountOfBags: selectedPickup.totalBags,
              ),
              const AppDivider(),
              Text(
                S.current.list_of_bags_in_pickup,
                style: AppTextStyle.smallBold(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: ClosedButtonsColumn(
                    closedBags: selectedPickup.bags ?? [],
                    selectedBag: null,
                    onPressed: onPressed,
                    openedReturn: openedReturn,
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
                      onPressed: () {
                        context.pop();
                      },
                      text: S.current.back,
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
