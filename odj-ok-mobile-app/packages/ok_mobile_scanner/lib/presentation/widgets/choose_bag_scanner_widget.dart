part of '../../../../../ok_mobile_scanner.dart';

class ChooseBagScannerWidget extends StatelessWidget {
  const ChooseBagScannerWidget({
    required this.onScanSuccess,
    this.disableContinousEditing = true,
    super.key,
  });

  final Future<bool> Function(String) onScanSuccess;
  final bool disableContinousEditing;

  @override
  Widget build(BuildContext context) {
    return BaseScannerWidget(
      onScanSuccess: onScanSuccess,
      upperTitle: S.current.scan_or_pick_bag_number,
      lowerTitle: '${S.current.or_enter_bag_number}:',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
