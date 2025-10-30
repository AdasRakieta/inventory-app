part of '../../ok_mobile_pickups.dart';

class PickupUneditableOverviewScreen extends StatelessWidget {
  const PickupUneditableOverviewScreen({super.key});

  static const routeName = '/pickup_uneditable_overview';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickupsCubit, PickupsState>(
      builder: (context, state) {
        return UneditableOverviewScreen(
          title: S.current.pickup_summary,
          selectedPickup: state.selectedPickup!,
          onPressed: (bag) {
            context.pushNamed(
              PickupClosedBagDetailsScreen.routeName,
              queryParameters: {
                PickupClosedBagDetailsScreen.hideManagementOptionsParam: 'true',
              },
              pathParameters: {
                PickupClosedBagDetailsScreen.selectedBagIdParam: bag.id!,
              },
            );
          },
        );
      },
    );
  }
}
