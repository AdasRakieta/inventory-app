part of '../../ok_mobile_returns.dart';

class SuccessReturnSummaryScreen extends StatelessWidget {
  const SuccessReturnSummaryScreen({required this.selectedReturnId, super.key});

  static const routeName = '/success_return_summary';
  static const currentReturnIdParam = 'selected_return_id';

  final String selectedReturnId;

  @override
  Widget build(BuildContext context) {
    return ReturnSummaryScreen(
      selectedReturnId: selectedReturnId,
      freshClose: true,
    );
  }
}
