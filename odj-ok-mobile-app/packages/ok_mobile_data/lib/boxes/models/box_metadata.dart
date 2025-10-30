part of '../../../ok_mobile_data.dart';

class BoxMetadata {
  BoxMetadata({required this.boxLabel, required this.collectionPointId});
  factory BoxMetadata.fromJson(Map<String, dynamic> json) {
    return BoxMetadata(
      boxLabel: json['label'] as String,
      collectionPointId: json['collectionPointId'] as String,
    );
  }
  final String boxLabel;
  final String collectionPointId;

  Map<String, dynamic> toJson() {
    return {'label': boxLabel, 'collectionPointId': collectionPointId};
  }
}
