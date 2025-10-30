part of '../../../../ok_mobile_data.dart';

enum BagType {
  can,
  plastic,
  mix,
  glass;

  String get localisedName {
    switch (this) {
      case BagType.can:
        return S.current.can;
      case BagType.plastic:
        return S.current.plastic;
      case BagType.glass:
        return S.current.glass;
      case BagType.mix:
        return S.current.mix;
    }
  }

  String get backendName {
    switch (this) {
      case BagType.can:
        return BagType.can.name;
      case BagType.plastic:
        return 'pet';
      case BagType.glass:
        return BagType.glass.name;
      case BagType.mix:
        return BagType.mix.name;
    }
  }
}

extension BagTypeTitleExtension on BagType {
  String title({bool isOpen = true}) {
    return switch (this) {
      BagType.mix =>
        isOpen
            ? S.current.open_bag.toUpperCase()
            : S.current.sealed_bag.toUpperCase(),
      _ =>
        '${isOpen ? S.current.open_bag : S.current.sealed}'
                ': $localisedName'
            .toUpperCase(),
    };
  }

  bool isGlass() => this == BagType.glass;
}

enum BagState { closed, open }

@immutable
class Bag extends Equatable {
  const Bag({
    required this.label,
    required this.type,
    required this.packages,
    this.state = BagState.closed,
    this.id,
    this.seal,
    this.boxId,
    this.closedTime,
    this.openedTime,
    this.itemsCount,
  });

  factory Bag.fromMetadata(BagMetadata metadata, String id) {
    return Bag(
      id: id,
      label: metadata.label,
      type:
          BagType.values.firstWhereOrNull(
            (element) =>
                element.backendName.toLowerCase() ==
                metadata.type.toLowerCase(),
          ) ??
          BagType.mix,
      packages: const <Package>[],
      state: BagState.open,
    );
  }

  factory Bag.fromJson(Map<String, dynamic> json) {
    return Bag(
      id: json['id'] as String?,
      label: json['label'] as String,
      type:
          BagType.values.firstWhereOrNull(
            (element) =>
                element.backendName.toLowerCase() ==
                (json['type'] as String?)?.toLowerCase(),
          ) ??
          BagType.mix,
      packages: json['items'] != null && (json['items'] as List).isNotEmpty
          ? (json['items'] as List<dynamic>)
                .map((e) => Package.fromJson(e as Map<String, dynamic>))
                .toList()
          : <Package>[],
      state: json['isOpen'] as bool? ?? false ? BagState.open : BagState.closed,
      closedTime: DateTime.parse(
        DatesHelper.asUTC(json['dateClosed'] as String?),
      ).toLocal(),
      openedTime: DateTime.parse(
        DatesHelper.asUTC(json['dateOpened'] as String?),
      ).toLocal(),
      seal: json['seal'] as String?,
      boxId: json['boxId'] as String?,
      itemsCount: json['itemsCount'] as int?,
    );
  }

  final String? id;
  final BagType type;
  final String label;
  final String? seal;
  final String? boxId;
  final BagState state;
  final DateTime? closedTime;
  final DateTime? openedTime;
  final List<Package> packages;
  final int? itemsCount;

  int get numberOfPackages {
    var number = 0;

    for (final package in packages) {
      number += package.quantity;
    }

    return number;
  }

  bool get isEmpty => label.isEmpty;

  Bag close() {
    return copyWith(state: BagState.closed, closedTime: DateTime.now());
  }

  Bag copyWith({
    String? id,
    BagType? type,
    String? label,
    BagState? state,
    DateTime? closedTime,
    DateTime? openedTime,
    List<Package>? packages,
    String? Function()? seal,
    String? boxId,
    int? itemsCount,
  }) {
    return Bag(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      state: state ?? this.state,
      closedTime: closedTime ?? this.closedTime,
      openedTime: openedTime ?? this.openedTime,
      packages: packages ?? this.packages,
      seal: seal != null ? seal() : this.seal,
      boxId: boxId ?? this.boxId,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }

  @override
  String toString() {
    return 'Bag{id: $id, type: $type, label: $label, state: $state, '
        'closedTime: $closedTime, openedTime: $openedTime, packages: $packages,'
        ' seal: $seal, itemsCount: $itemsCount}';
  }

  @override
  List<Object?> get props => [id, numberOfPackages, seal, label];
}
