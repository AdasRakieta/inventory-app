part of '../../../ok_mobile_data.dart';

class PickupPackageData {
  PickupPackageData({required this.packageMaterial, required this.quantity});

  factory PickupPackageData.fromJson(Map<String, dynamic> json) {
    return PickupPackageData(
      packageMaterial:
          ReturnsHelper.resolveBagType(json['packageMaterial'] as String) ??
          BagType.mix,
      quantity: json['quantity'] as int,
    );
  }

  final BagType packageMaterial;
  final int quantity;

  @override
  String toString() {
    return 'PickupPackageData(packageMaterial: $packageMaterial, '
        'quantity: $quantity)';
  }
}
