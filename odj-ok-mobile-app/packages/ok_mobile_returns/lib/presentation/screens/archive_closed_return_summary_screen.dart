part of '../../ok_mobile_returns.dart';

class ArchiveClosedReturnSummaryScreen extends StatelessWidget {
  const ArchiveClosedReturnSummaryScreen({
    required this.selectedReturnId,
    super.key,
  });

  static const routeName = '/archive_closed_return_summary';
  static const currentReturnIdParam = 'selected_return_id';

  final String selectedReturnId;

  @override
  Widget build(BuildContext context) {
    return ReturnSummaryScreen(
      selectedReturnId: selectedReturnId,
      showBackButton: true,
      backToClosed: false,
      allowVoucherReprint: true,
    );
  }
}
