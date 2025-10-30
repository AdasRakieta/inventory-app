part of '../../ok_mobile_pickups.dart';

class PickupClosedBagDetailsScreen extends StatelessWidget {
  const PickupClosedBagDetailsScreen({
    required this.selectedBagId,
    this.hideManagementOptions = false,
    this.bagsFromPickup = false,
    super.key,
  });
  static const routeName = '/pickup_closed_bag_details';
  static const hideManagementOptionsParam = 'hide_management_options';
  static const selectedBagIdParam = 'selected_bag_id_param';

  final bool hideManagementOptions;
  final String selectedBagId;
  final bool bagsFromPickup;

  @override
  Widget build(BuildContext context) {
    return ClosedBagDetailsScreen(
      hideManagementOptions: hideManagementOptions,
      selectedBagId: selectedBagId,
      bagsList: context.watch<PickupsCubit>().state.selectedPickup?.bags,
    );
  }
}
