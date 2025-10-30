part of '../../../ok_mobile_data.dart';

class Receival {
  Receival({required this.countingCenterId, this.bagIds});

  final String countingCenterId;
  final List<SimpleDto>? bagIds;

  Map<String, dynamic> toJson() {
    return {
      'bags': bagIds?.map((bagId) => bagId.toJson()).toList() ?? [],
      'countingCenterId': countingCenterId,
    };
  }
}
