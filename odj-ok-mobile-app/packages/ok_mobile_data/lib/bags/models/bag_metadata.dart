part of '../../../../ok_mobile_data.dart';

class BagMetadata {
  const BagMetadata({
    required this.type,
    required this.label,
    required this.collectionPointId,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'type': type,
      'collectionPointId': collectionPointId,
    };
  }

  final String type;
  final String label;
  final String collectionPointId;
}
