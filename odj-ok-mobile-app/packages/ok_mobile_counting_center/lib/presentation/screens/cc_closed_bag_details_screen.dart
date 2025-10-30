part of '../../ok_mobile_counting_center.dart';

class CCClosedBagDetailsScreen extends StatelessWidget {
  const CCClosedBagDetailsScreen({
    required this.selectedBagId,
    this.hideManagementOptions = false,
    this.bagsFromPickup = false,
    super.key,
  });
  static const routeName = '/cc_closed_bag_details';
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
      bagsList: context.watch<ReceivalsCubit>().state.selectedReceival!.bags,
    );
  }
}
