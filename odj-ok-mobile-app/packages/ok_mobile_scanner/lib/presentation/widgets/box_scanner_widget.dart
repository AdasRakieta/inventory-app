part of '../../../../../ok_mobile_scanner.dart';

class BoxScannerWidget extends StatelessWidget {
  const BoxScannerWidget({
    required this.onScanSuccess,
    this.upperTitle,
    super.key,
    this.disableContinousEditing = true,
  });

  final Future<bool> Function(String) onScanSuccess;
  final String? upperTitle;
  final bool disableContinousEditing;

  @override
  Widget build(BuildContext context) {
    // TODO enable boxes when ready
    // return BlocBuilder<BoxCubit, BoxState>(
    //   builder: (context, state) {
    //     return BaseScannerWidget(
    //       onScanSuccess: onScanSuccess,
    //       upperTitle: upperTitle ?? S.current.scan_new_box,
    //       lowerTitle: '${S.current.or_enter_box_number}:',
    //       isFailure: state.result is Failure,
    //       keyboardType: TextInputType.number,
    //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    //       onInputCompleteResult: disableContinousEditing,
    //     );
    //   },
    // );
    return Container();
  }
}
