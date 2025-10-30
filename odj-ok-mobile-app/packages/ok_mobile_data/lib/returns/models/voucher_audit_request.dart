part of '../../../../ok_mobile_data.dart';

enum AuditEvent {
  invalid,
  printRequested,
  printSuccess,
  printAborted,
  reprintRequested,
}

class VoucherAuditRequest {
  VoucherAuditRequest({required this.event, this.reason});
  final AuditEvent event;

  final ActionReason? reason;

  Map<String, dynamic> toJson() {
    return {'event': event.name, 'reason': reason?.jsonKey};
  }
}
