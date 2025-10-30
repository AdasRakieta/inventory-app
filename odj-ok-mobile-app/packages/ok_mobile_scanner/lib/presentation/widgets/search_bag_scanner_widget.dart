part of '../../../../../ok_mobile_scanner.dart';

class SearchBagScannerWidget extends StatelessWidget {
  const SearchBagScannerWidget({required this.onScanSuccess, super.key});

  final Future<bool> Function(String) onScanSuccess;

  @override
  Widget build(BuildContext context) {
    return BaseScannerWidget(
      onScanSuccess: onScanSuccess,
      upperTitle: S.current.scan_or_pick_bag_number,
      lowerTitle: '${S.current.or_enter_label_number}:',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
