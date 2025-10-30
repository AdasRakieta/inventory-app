part of '../../../ok_mobile_data.dart';

class CCPickupData extends Equatable {
  const CCPickupData({
    required this.id,
    required this.dateAdded,
    required this.dateModified,
    required this.status,
    required this.code,
    this.countingCenter,
    this.bagsCount,
    this.collectionPoint,
    this.statusHistory,
    this.packagesReleased,
    this.bags,
    this.boxes,
  });

  factory CCPickupData.fromJson(Map<String, dynamic> json) {
    return CCPickupData(
      id: json['id'] as String,
      dateAdded: DateTime.parse(
        DatesHelper.asUTC(json['dateAdded'] as String),
      ).toLocal(),
      dateModified: DateTime.parse(
        DatesHelper.asUTC(json['dateModified'] as String),
      ).toLocal(),
      status: PickupStatus.values.firstWhere(
        (e) => e.jsonKey == json['status'] as String,
      ),
      code: json['code'] as String,
      countingCenter: json['countingCenter'] != null
          ? ContractorData.fromJson(
              json['countingCenter'] as Map<String, dynamic>,
            )
          : null,
      collectionPoint: ContractorData.fromJson(
        json['collectionPoint'] as Map<String, dynamic>,
      ),
      bagsCount: json['bagsCount'] as int?,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map(
            (history) =>
                CCStatusHistoryData.fromJson(history as Map<String, dynamic>),
          )
          .toList(),
      packagesReleased: (json['packagesReleased'] as List<dynamic>?)
          ?.map(
            (package) => CCPackageAggregateData.fromJson(
              package as Map<String, dynamic>,
            ),
          )
          .toList(),
      bags: (json['bags'] as List<dynamic>?)
          ?.map((bag) => Bag.fromJson(bag as Map<String, dynamic>))
          .toList(),
      boxes: (json['boxes'] as List<dynamic>?)
          ?.map((box) => Box.fromJson(box as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final DateTime dateAdded;
  final DateTime dateModified;
  final PickupStatus status;
  final String code;
  final ContractorData? countingCenter;
  final int? bagsCount;
  final ContractorData? collectionPoint;
  final List<CCStatusHistoryData>? statusHistory;
  final List<CCPackageAggregateData>? packagesReleased;
  final List<Bag>? bags;
  final List<Box>? boxes;

  @override
  List<Object?> get props => [
    id,
    dateAdded,
    dateModified,
    status,
    code,
    countingCenter,
    bagsCount,
    collectionPoint,
    statusHistory,
    packagesReleased,
    bags,
    boxes,
  ];
}

class CCPackageAggregateData extends Equatable {
  const CCPackageAggregateData({
    required this.packageMaterial,
    required this.quantity,
  });

  factory CCPackageAggregateData.fromJson(Map<String, dynamic> json) {
    return CCPackageAggregateData(
      packageMaterial: ReturnsHelper.resolveBagType(
        json['packageMaterial'] as String,
      )!,
      quantity: json['quantity'] as int,
    );
  }

  final BagType packageMaterial;
  final int quantity;

  Map<String, dynamic> toJson() {
    return {'packageMaterial': packageMaterial, 'quantity': quantity};
  }

  @override
  List<Object?> get props => [packageMaterial, quantity];
}

class CCStatusHistoryData extends Equatable {
  const CCStatusHistoryData({required this.dateModified, required this.status});

  factory CCStatusHistoryData.fromJson(Map<String, dynamic> json) {
    return CCStatusHistoryData(
      dateModified: DateTime.parse(
        DatesHelper.asUTC(json['dateModified'] as String),
      ).toLocal(),
      status: json['status'] as String,
    );
  }

  final DateTime dateModified;
  final String status;

  Map<String, dynamic> toJson() {
    return {'dateModified': dateModified.toIso8601String(), 'status': status};
  }

  @override
  List<Object?> get props => [dateModified, status];
}
