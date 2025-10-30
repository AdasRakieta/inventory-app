part of '../../../../ok_mobile_data.dart';

class ReturnMetadata {
  ReturnMetadata({required this.id, required this.code});

  factory ReturnMetadata.fromJson(Map<String, dynamic> json) {
    return ReturnMetadata(
      id: json['id'] as String,
      code: json['code'] as String,
    );
  }
  final String id;
  final String code;
}
