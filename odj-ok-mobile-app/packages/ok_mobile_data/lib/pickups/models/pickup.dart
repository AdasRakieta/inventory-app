part of '../../../../ok_mobile_data.dart';

enum PickupStatus {
  released(jsonKey: 'Released'),
  partiallyReceived(jsonKey: 'PartiallyReceived'),
  received(jsonKey: 'Received'),
  futureReceived;

  const PickupStatus({this.jsonKey});

  final String? jsonKey;

  String get localizedName {
    switch (this) {
      case PickupStatus.released:
        return S.current.released;
      case PickupStatus.partiallyReceived:
        return S.current.partially_received;
      case PickupStatus.received:
      case PickupStatus.futureReceived:
        return S.current.received_in_cc;
    }
  }
}

class Pickup extends Equatable {
  @immutable
  const Pickup({
    required this.dateAdded,
    this.id,
    this.code,
    this.status,
    this.dateModified,
    this.packages,
    this.bags,
    this.statusHistory,
    this.countingCenter,
    this.collectionPoint,
    this.bagsCount,
  });

  factory Pickup.empty() {
    return Pickup(
      dateAdded: DateTime.now(),
      packages: const [],
      bags: const [],
      statusHistory: const [],
    );
  }

  factory Pickup.fromJson(Map<String, dynamic> json) {
    return Pickup(
      id: json['id'] as String?,
      code: json['code'] as String,
      status: PickupStatus.values.firstWhere(
        (e) => e.jsonKey == json['status'],
      ),
      dateAdded: DateTime.parse(
        DatesHelper.asUTC(json['dateAdded'] as String),
      ).toLocal(),
      dateModified: json['dateModified'] != null
          ? DateTime.parse(
              DatesHelper.asUTC(json['dateModified'] as String),
            ).toLocal()
          : null,
      packages: (json['packagesReleased'] as List<dynamic>?)
          ?.map((e) => PickupPackageData.fromJson(e as Map<String, dynamic>))
          .toList(),
      bags: (json['bags'] as List<dynamic>?)
          ?.map((e) => Bag.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => StatusHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      collectionPoint: json['collectionPoint'] != null
          ? ContractorData.fromJson(
              json['collectionPoint'] as Map<String, dynamic>,
            )
          : null,
      countingCenter: json['countingCenter'] != null
          ? ContractorData.fromJson(
              json['countingCenter'] as Map<String, dynamic>,
            )
          : null,
      bagsCount: json['bagsCount'] as int?,
    );
  }

  final String? id;
  final String? code;
  final PickupStatus? status;
  final DateTime dateAdded;
  final DateTime? dateModified;
  final List<PickupPackageData>? packages;
  final List<Bag>? bags;
  final List<StatusHistoryItem>? statusHistory;
  final ContractorData? countingCenter;
  final ContractorData? collectionPoint;
  final int? bagsCount;

  int get petQuantity {
    return packages
            ?.firstWhereOrNull(
              (element) => element.packageMaterial == BagType.plastic,
            )
            ?.quantity ??
        0;
  }

  int get canQuantity {
    return packages
            ?.firstWhereOrNull(
              (element) => element.packageMaterial == BagType.can,
            )
            ?.quantity ??
        0;
  }

  Pickup addBags(List<Bag> newBags) {
    return copyWith(bags: [...newBags, ...?bags]);
  }

  int get totalBags => bags?.length ?? 0;

  List<StatusHistoryItem> get statusHistoryWithCurrent {
    final currentStatusAsHistoryItem = StatusHistoryItem(
      dateModified: dateModified,
      status: status!,
    );

    return [
      ...?statusHistory,
      currentStatusAsHistoryItem,
      if (statusHistory == null || statusHistory!.isEmpty)
        StatusHistoryItem(status: PickupStatus.futureReceived),
    ];
  }

  Pickup copyWith({
    String? id,
    String? code,
    PickupStatus? status,
    DateTime? dateAdded,
    DateTime? dateModified,
    List<PickupPackageData>? packages,
    List<Bag>? bags,
    List<StatusHistoryItem>? statusHistory,
    ContractorData? countingCenter,
    ContractorData? collectionPoint,
    int? bagsCount,
  }) {
    return Pickup(
      id: id ?? this.id,
      code: code ?? this.code,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      packages: packages ?? this.packages,
      bags: bags ?? this.bags,
      statusHistory: statusHistory ?? this.statusHistory,
      countingCenter: countingCenter ?? this.countingCenter,
      collectionPoint: collectionPoint ?? this.collectionPoint,
      bagsCount: bagsCount ?? this.bagsCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    status,
    dateAdded,
    dateModified,
    packages,
    bags,
    statusHistory,
    countingCenter,
    collectionPoint,
    bagsCount,
  ];

  @override
  String toString() {
    return 'Pickup(id: $id, code: $code, status: $status, dateAdded: '
        '$dateAdded, dateModified: $dateModified, packages: $packages, bags:'
        ' $bags, statusHistory: $statusHistory, countingCenter: '
        '$countingCenter, collectionPoint: $collectionPoint, '
        'bagCount: $bagsCount)';
  }
}
