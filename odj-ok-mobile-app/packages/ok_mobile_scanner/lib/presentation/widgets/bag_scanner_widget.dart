part of '../../../../../ok_mobile_scanner.dart';

class BagScannerWidget extends StatelessWidget {
  const BagScannerWidget({
    required this.onScanSuccess,
    super.key,
    this.type,
    this.title,
    this.subtitle,
    this.disableContinousEditing = true,
  });

  final BagType? type;
  final Future<bool> Function(String) onScanSuccess;
  final String? title;
  final String? subtitle;
  final bool disableContinousEditing;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BagsCubit, BagsState>(
      builder: (context, state) {
        return BaseScannerWidget(
          onScanSuccess: onScanSuccess,
          upperTitle: title ?? S.current.scan_new_bag,
          lowerTitle: '${subtitle ?? S.current.or_enter_bag_number}:',
          isFailure: state.result is Failure,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onInputCompleteResult: disableContinousEditing,
        );
      },
    );
  }
}
