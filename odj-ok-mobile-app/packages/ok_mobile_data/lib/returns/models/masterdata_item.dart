part of '../../../../ok_mobile_data.dart';

enum PackageType {
  invalid(jsonKey: 'Invalid'),
  plastic(jsonKey: 'Plastic'),
  can(jsonKey: 'Can'),
  glass(jsonKey: 'Glass'),
  box(jsonKey: 'Box'),
  bottleInBox(jsonKey: 'BottleInBox'),
  carton(jsonKey: 'Carton'),
  pouch(jsonKey: 'Pouch'),
  jar(jsonKey: 'Jar'),
  tube(jsonKey: 'Tube');

  const PackageType({required this.jsonKey});

  final String jsonKey;
}

class MasterdataItem {
  MasterdataItem({
    required this.ean,
    this.depositAmountNet,
    this.packageType,
    this.productNameShort,
  });

  factory MasterdataItem.fromJson(Map<String, dynamic> json) {
    return MasterdataItem(
      ean: json['ean'] as String,
      productNameShort: json['productNameShort'] as String?,
      depositAmountNet: json['depositAmountNet'] as double?,
      packageType: PackageType.values.firstWhereOrNull(
        (e) => e.jsonKey == json['packageType'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ean': ean,
      'productNameShort': productNameShort,
      'depositAmountNet': depositAmountNet,
      'packageType': packageType?.jsonKey,
    };
  }

  final String ean;
  final String? productNameShort;
  final double? depositAmountNet;
  final PackageType? packageType;
}
