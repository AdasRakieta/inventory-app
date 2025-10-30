part of '../../ok_mobile_returns.dart';

class ClosedReturnSummaryScreen extends StatelessWidget {
  const ClosedReturnSummaryScreen({
    required this.selectedReturnId,
    required this.showBackButton,
    super.key,
  });

  static const routeName = '/closed_return_summary';
  static const currentReturnIdParam = 'selected_return_id';
  static const shouldShowBackButtonParam = 'shoud_show_back_button';

  final String selectedReturnId;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return ReturnSummaryScreen(
      selectedReturnId: selectedReturnId,
      allowVoucherReprint: true,
      showBackButton: showBackButton,
    );
  }
}
