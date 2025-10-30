part of '../../../ok_mobile_data.dart';

class PickupMetadata {
  PickupMetadata({required this.collectionPointId, this.bagIds, this.boxIds});

  final String collectionPointId;
  final List<SimpleDto>? bagIds;
  final List<SimpleDto>? boxIds;

  Map<String, dynamic> toJson() {
    return {
      'bags': bagIds?.map((bagId) => bagId.toJson()).toList() ?? [],
      'boxes': boxIds?.map((boxId) => boxId.toJson()).toList() ?? [],
      'collectionPointId': collectionPointId,
    };
  }
}
