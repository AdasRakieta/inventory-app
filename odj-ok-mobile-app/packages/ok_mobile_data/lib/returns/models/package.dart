part of '../../../../ok_mobile_data.dart';

class Package {
  Package({
    required this.eanCode,
    BagType? type,
    this.bagId,
    this.description,
    int? quantity,
    double? deposit,
  }) {
    _quantity = quantity ?? 1;
    _deposit = deposit ?? 0;
    _type = type;
  }

  factory Package.fromMasterdata(MasterdataItem item) {
    return Package(
      eanCode: item.ean,
      description: item.productNameShort ?? '',
      deposit: item.depositAmountNet ?? 0,
      type: ReturnsHelper.resolveBagTypeV2(item.packageType),
    );
  }

  factory Package.fromBagItemEntity(BagItem item) {
    return Package(
      eanCode: item.ean!,
      quantity: item.quantity,
      deposit: item.depositValue,
    );
  }

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      eanCode: json['ean'] as String? ?? json['eanCode'] as String,
      description: json['description'] as String?,
      bagId: json['bagId'] as String?,
      type: json['type'] != null
          ? BagType.values.firstWhere((e) => e.toString() == json['type'])
          : null,
      quantity: json['quantity'] as int?,
      deposit: (json['deposit'] as num?)?.toDouble(),
    );
  }

  final String eanCode;
  final String? description;
  final String? bagId;
  BagType? _type;
  int _quantity = 1;
  double _deposit = 0;

  int get quantity => _quantity;
  double get deposit => _deposit;
  BagType? get type => _type;

  void increaseQuantity({int amount = 1}) {
    _quantity += amount;
  }

  void decreaseQuantity() {
    _quantity--;
  }

  Package copyWith({
    String? eanCode,
    String? bagId,
    String? description,
    BagType? type,
    int? quantity,
    double? deposit,
  }) {
    return Package(
      eanCode: eanCode ?? this.eanCode,
      bagId: bagId ?? this.bagId,
      description: description ?? this.description,
      type: type ?? _type,
      quantity: quantity ?? _quantity,
      deposit: deposit ?? _deposit,
    );
  }

  Package copy() {
    return Package(
      eanCode: eanCode,
      bagId: bagId,
      description: description,
      type: _type,
      quantity: _quantity,
      deposit: _deposit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eanCode': eanCode,
      'description': description,
      'bagId': bagId,
      'type': _type?.toString(),
      'quantity': _quantity,
      'deposit': _deposit,
    };
  }
}
