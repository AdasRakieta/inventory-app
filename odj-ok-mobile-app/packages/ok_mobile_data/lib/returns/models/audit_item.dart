part of '../../../../ok_mobile_data.dart';

class AuditItem {
  AuditItem({required this.type, required this.dateOccurred, this.reason});

  factory AuditItem.fromJson(Map<String, dynamic> json) {
    return AuditItem(
      type: json['type'] as String,
      dateOccurred: DateTime.parse(json['dateOccurred'] as String),
      reason: ActionReason.values.firstWhereOrNull(
        (e) => e.jsonKey == json['reason'] as String?,
      ),
    );
  }
  final String type;
  final DateTime dateOccurred;
  final ActionReason? reason;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'dateOccurred': dateOccurred,
      'reason': reason?.jsonKey,
    };
  }

  @override
  String toString() {
    return 'AuditItemEntity(type: $type, dateOccurred: $dateOccurred, '
        'reason: ${reason?.name})';
  }
}
