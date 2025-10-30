part of '../../../../../ok_mobile_scanner.dart';

class SealScannerWidget extends StatelessWidget {
  const SealScannerWidget({
    required this.onScanSuccess,
    required this.title,
    super.key,
    this.type,
  });

  final BagType? type;
  final String title;
  final Future<bool> Function(String) onScanSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BagsCubit, BagsState>(
      builder: (context, state) {
        return BaseScannerWidget(
          onScanSuccess: onScanSuccess,
          upperTitle: title,
          lowerTitle: S.current.or_enter_seal_number,
          isFailure: state.result is Failure,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          clearOnComplete: state.result is! Failure,
        );
      },
    );
  }
}
