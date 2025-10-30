part of '../../../../../ok_mobile_scanner.dart';

class CCSealScannerWidget extends StatelessWidget {
  const CCSealScannerWidget({
    required this.onScanSuccess,
    required this.title,
    this.isFailure = false,
    super.key,
  });

  final String title;
  final bool isFailure;
  final Future<bool> Function(String) onScanSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceivalsCubit, ReceivalsState>(
      builder: (context, state) {
        return BaseScannerWidget(
          onScanSuccess: onScanSuccess,
          upperTitle: title,
          lowerTitle: S.current.or_enter_seal_number,
          isFailure: isFailure,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          clearOnComplete: state.result is! Failure,
        );
      },
    );
  }
}
