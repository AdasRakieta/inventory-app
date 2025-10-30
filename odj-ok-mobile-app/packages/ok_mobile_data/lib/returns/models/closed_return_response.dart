part of '../../../../ok_mobile_data.dart';

class ClosedReturnResponse {
  ClosedReturnResponse({
    required this.voucherEntity,
    required this.closedReturn,
  });

  factory ClosedReturnResponse.fromJson(Map<String, dynamic> json) {
    return ClosedReturnResponse(
      closedReturn: ReturnMetadata.fromJson(
        json['manualCollection'] as Map<String, dynamic>,
      ),
      voucherEntity: Voucher.fromJson(json['voucher'] as Map<String, dynamic>),
    );
  }

  final ReturnMetadata closedReturn;
  final Voucher voucherEntity;
}
