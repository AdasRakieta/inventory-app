part of '../../ok_mobile_returns.dart';

class ArchiveConfirmVoucherPrintScreen extends StatelessWidget {
  const ArchiveConfirmVoucherPrintScreen({
    required this.selectedReturnId,
    super.key,
  });

  static const routeName = '/archive_confirm_voucher_print';
  static const currentReturnIdParam = 'selected_return_id';

  final String selectedReturnId;

  @override
  Widget build(BuildContext context) {
    return ConfirmVoucherPrintScreen(
      selectedReturnId: selectedReturnId,
      backToClosed: false,
    );
  }
}
