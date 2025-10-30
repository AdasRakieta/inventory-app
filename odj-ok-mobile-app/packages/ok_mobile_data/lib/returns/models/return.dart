part of '../../../../ok_mobile_data.dart';

enum ReturnState { canceled, ongoing, printed, unfinished }

class Return {
  Return({
    required this.id,
    required this.packages,
    required this.state,
    this.voucher,
    this.voucherCancellationReason,
    this.code,
    this.mostRecentPackage,
    DateTime? closedTime,
  }) {
    _closedTime = closedTime;
  }

  factory Return.empty() {
    return Return(id: '', packages: [], state: ReturnState.ongoing);
  }

  factory Return.fromEntity(ClosedReturn entity) {
    var state = ReturnState.unfinished;

    if (entity.voucher.auditItem?.type ==
        AuditEvent.printSuccess.name.capitalize()) {
      state = ReturnState.printed;
    } else if (entity.voucher.auditItem?.reason != null) {
      state = ReturnState.canceled;
    }

    return Return(
      id: entity.id,
      code: entity.code,
      closedTime: DateTime.parse(DatesHelper.asUTC(entity.dateAdded)).toLocal(),
      packages: entity.items.map(Package.fromBagItemEntity).toList(),
      voucher: entity.voucher,
      voucherCancellationReason: entity.voucher.auditItem?.reason,
      state: state,
    );
  }

  factory Return.fromJson(Map<String, dynamic> json) {
    return Return(
      id: json['id'] as String,
      packages: (json['packages'] as List<dynamic>)
          .map((package) => Package.fromJson(package as Map<String, dynamic>))
          .toList(),
      voucher: json['voucher'] != null
          ? Voucher.fromJson(json['voucher'] as Map<String, dynamic>)
          : null,
      voucherCancellationReason: ActionReason.values.firstWhereOrNull(
        (e) => e.name == json['reason'] as String?,
      ),
      code: json['code'] as String?,
      closedTime: json['closedTime'] != null
          ? DateTime.tryParse(json['closedTime'] as String)
          : null,
      state: ReturnState.values.byName(json['state'] as String),
      mostRecentPackage: json['mostRecentPackage'] != null
          ? Package.fromJson(json['mostRecentPackage'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final List<Package> packages;
  final Voucher? voucher;
  final ActionReason? voucherCancellationReason;
  DateTime? _closedTime;
  Package? mostRecentPackage;
  String? code;
  ReturnState state;

  DateTime? get closedTime => _closedTime;

  bool get isReadyToClose {
    if (numberOfPackages == 0) return false;
    if (numberOfPackages == 1 &&
        packages.first.type != BagType.glass &&
        packages.first.bagId == null) {
      return false;
    }
    return true;
  }

  int get numberOfPackages {
    const initialValue = 0;
    return packages.fold<int>(initialValue, (previousValue, element) {
      return previousValue + element.quantity;
    });
  }

  int numberOfPackagesInBag(String bagId) {
    return packages.where((element) => element.bagId == bagId).fold<int>(0, (
      previousValue,
      element,
    ) {
      return previousValue + element.quantity;
    });
  }

  void increasePackageQuantity(String ean, String bagId) {
    final existingPackage = packages.firstWhereOrNull(
      (element) => element.eanCode == ean && element.bagId == bagId,
    );

    if (existingPackage != null) {
      existingPackage.increaseQuantity();
    }
  }

  void decreasePackageQuantity(String ean, String? bagId, BagType? bagType) {
    Package? existingPackage;
    if (bagId == null && bagType == BagType.glass) {
      // for glass we don't have bagId associated with the package
      existingPackage = packages.firstWhereOrNull(
        (element) => element.eanCode == ean,
      );
    } else {
      existingPackage = packages.firstWhereOrNull(
        (element) => element.eanCode == ean && element.bagId == bagId,
      );
    }

    if (existingPackage != null) {
      existingPackage.decreaseQuantity();
    }
  }

  void addPackage(Package package) {
    final existingPackage = packages.firstWhereOrNull(
      (element) =>
          element.eanCode == package.eanCode && element.bagId == package.bagId,
    );

    if (existingPackage == null) {
      packages.insert(0, package.copy());
    } else {
      existingPackage.increaseQuantity();
      packages
        ..removeWhere(
          (element) =>
              element.bagId == existingPackage.bagId &&
              element.eanCode == existingPackage.eanCode,
        )
        ..insert(0, existingPackage);
    }
  }

  void removePackage(String ean, String? bagId, BagType? bagType) {
    if (bagId == null && bagType == BagType.glass) {
      // for glass we don't have bagId associated with the package
      packages.removeWhere((element) => element.eanCode == ean);
    } else {
      packages.removeWhere(
        (element) => element.eanCode == ean && element.bagId == bagId,
      );
    }
  }

  Return copyWith({
    String? id,
    DateTime? closedTime,
    List<Package>? packages,
    Voucher? voucher,
    String? code,
    ReturnState? state,
    ActionReason? voucherCancellationReason,
    Package? Function()? mostRecentPackage,
  }) {
    return Return(
      id: id ?? this.id,
      closedTime: closedTime ?? this.closedTime,
      packages: packages ?? this.packages,
      voucher: voucher ?? this.voucher,
      voucherCancellationReason:
          voucherCancellationReason ?? this.voucherCancellationReason,
      code: code ?? this.code,
      state: state ?? this.state,
      mostRecentPackage: mostRecentPackage != null
          ? mostRecentPackage()
          : this.mostRecentPackage,
    );
  }

  @override
  String toString() {
    return 'Return(id: $id, packages: $packages, voucher: $voucher, '
        'voucherCancellationReason: $voucherCancellationReason, code: $code, '
        'closedTime: $_closedTime, state: $state,'
        ' mostRecentPackage: $mostRecentPackage)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packages': packages.map((package) => package.toJson()).toList(),
      'voucher': voucher?.toJson(),
      'reason': voucherCancellationReason?.jsonKey,
      'code': code,
      'closedTime': _closedTime?.toIso8601String(),
      'state': state.name,
      'mostRecentPackage': mostRecentPackage?.toJson(),
    };
  }
}
