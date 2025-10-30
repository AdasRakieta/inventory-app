part of '../../../../ok_mobile_data.dart';

class ClosedReturn {
  ClosedReturn({
    required this.id,
    required this.code,
    required this.dateAdded,
    required this.items,
    required this.voucher,
  });

  factory ClosedReturn.fromJson(Map<String, dynamic> json) {
    return ClosedReturn(
      code: json['code'] as String,
      id: json['id'] as String,
      dateAdded: json['dateAdded'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => BagItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      voucher: Voucher.fromJson(json['voucher'] as Map<String, dynamic>),
    );
  }
  final String id;
  final String code;
  final String dateAdded;
  final List<BagItem> items;
  final Voucher voucher;
}
