part of '../../../../ok_mobile_data.dart';

class Voucher {
  Voucher({
    required this.id,
    required this.code,
    this.depositValue,
    this.auditItem,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] as String,
      code: json['code'] as String,
      depositValue: json['depositValue'] as double?,
      auditItem: json['lastAuditItem'] != null
          ? AuditItem.fromJson(json['lastAuditItem'] as Map<String, dynamic>)
          : null,
    );
  }
  final String id;
  final String code;
  final double? depositValue;
  final AuditItem? auditItem;

  Voucher copyWith({
    String? id,
    String? code,
    double? depositValue,
    AuditItem? auditItem,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      depositValue: depositValue ?? this.depositValue,
      auditItem: auditItem ?? this.auditItem,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'depositValue': depositValue,
      'auditItem': auditItem?.toJson(),
    };
  }
}
