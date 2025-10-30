part of '../../../../ok_mobile_data.dart';

class BagItem {
  BagItem({this.ean, this.quantity, this.depositValue, this.bagId});

  factory BagItem.fromDomain(Package package) {
    return BagItem(
      ean: package.eanCode,
      quantity: package.quantity,
      bagId: package.bagId,
    );
  }

  factory BagItem.fromJson(Map<String, dynamic> json) {
    return BagItem(
      ean: json['ean'] as String?,
      quantity: json['quantity'] as int?,
      depositValue: json['depositValue'] as double?,
    );
  }

  final String? ean;
  final int? quantity;
  final double? depositValue;
  final String? bagId;

  Map<String, dynamic> toJson() {
    return {'quantity': quantity, 'ean': ean, 'bagId': bagId};
  }
}
