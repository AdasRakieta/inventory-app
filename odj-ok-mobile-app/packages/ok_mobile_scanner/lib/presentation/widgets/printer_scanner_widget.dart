part of '../../../../../ok_mobile_scanner.dart';

class PrinterScannerWidget extends StatelessWidget {
  const PrinterScannerWidget({required this.onScanSuccess, super.key});

  final Future<bool> Function(String) onScanSuccess;

  @override
  Widget build(BuildContext context) => BaseScannerWidget(
    onScanSuccess: onScanSuccess,
    upperTitle: S.current.scan_new_printer_code,
    lowerTitle: '${S.current.or_enter_number}:',
    cameraCodeFormats: const [BarcodeFormat.qrCode],
    scannerCodeFormats: [BarcodeConfig(barcodeType: BarcodeTypes.qrCode)],
    keyboardType: TextInputType.text,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9:]')),
    ],
    clearOnComplete: true,
    onInputCompleteResult: false,
  );
}
