part of '../ok_mobile_data.dart';

class FailureEntity {
  FailureEntity({
    required this.type,
    required this.status,
    required this.detail,
    required this.errors,
  });

  factory FailureEntity.fromJson(Map<String, dynamic> json) {
    return FailureEntity(
      type: json['type'] as String,
      status: json['status'] as int,
      detail: json['detail'] as String?,
      errors: json['errors'] != null
          ? Map<String, List<dynamic>>.from(json['errors'] as Map)
          : null,
    );
  }

  final String type;
  final int status;
  final String? detail;
  final Map<String, List<dynamic>>? errors;

  @override
  String toString() {
    return 'FailureEntity(type: $type, status: $status, '
        'detail: $detail, errors: $errors)';
  }
}
