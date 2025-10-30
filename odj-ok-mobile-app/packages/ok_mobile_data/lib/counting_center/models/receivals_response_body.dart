part of '../../../ok_mobile_data.dart';

abstract class ReceivalResponseBody {
  ReceivalResponseBody({
    required this.pickups,
    required List<CCPackageAggregateData> packages,
  }) : _packages = packages;

  List<CCPickupData> pickups;
  final List<CCPackageAggregateData> _packages;

  List<CCPackageAggregateData> get packages => _packages;
}

class CollectedReceivalsResponseBody extends ReceivalResponseBody {
  CollectedReceivalsResponseBody({
    required super.pickups,
    required List<CCPackageAggregateData> packagesReceived,
  }) : super(packages: packagesReceived);

  factory CollectedReceivalsResponseBody.fromJson(Map<String, dynamic> json) {
    return CollectedReceivalsResponseBody(
      pickups:
          (json['pickups'] as List<dynamic>?)
              ?.map(
                (pickup) =>
                    CCPickupData.fromJson(pickup as Map<String, dynamic>),
              )
              .toList() ??
          [],
      packagesReceived:
          (json['packagesReceived'] as List<dynamic>?)
              ?.map(
                (package) => CCPackageAggregateData.fromJson(
                  package as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class PlannedReceivalsResponseBody extends ReceivalResponseBody {
  PlannedReceivalsResponseBody({
    required super.pickups,
    required List<CCPackageAggregateData> packagesReleased,
  }) : super(packages: packagesReleased);

  factory PlannedReceivalsResponseBody.fromJson(Map<String, dynamic> json) {
    return PlannedReceivalsResponseBody(
      pickups:
          (json['pickups'] as List<dynamic>?)
              ?.map(
                (pickup) =>
                    CCPickupData.fromJson(pickup as Map<String, dynamic>),
              )
              .toList() ??
          [],
      packagesReleased:
          (json['packagesReleased'] as List<dynamic>?)
              ?.map(
                (package) => CCPackageAggregateData.fromJson(
                  package as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class ReceivalsResponse extends Equatable {
  const ReceivalsResponse({required this.ccPickups, required this.packages});

  factory ReceivalsResponse.fromResponseBody(
    ReceivalResponseBody responseBody,
  ) {
    return ReceivalsResponse(
      ccPickups: responseBody.pickups,
      packages: responseBody.packages,
    );
  }

  final List<CCPickupData> ccPickups;
  final List<CCPackageAggregateData> packages;

  int get petQuantity {
    return packages
            .firstWhereOrNull(
              (element) => element.packageMaterial == BagType.plastic,
            )
            ?.quantity ??
        0;
  }

  int get canQuantity {
    return packages
            .firstWhereOrNull(
              (element) => element.packageMaterial == BagType.can,
            )
            ?.quantity ??
        0;
  }

  @override
  List<Object?> get props => [ccPickups, packages];
}
