part of '../../../../ok_mobile_data.dart';

class ReturnDto {
  ReturnDto({
    required this.items,
    required this.collectionPointId,
    required this.deviceId,
  });

  factory ReturnDto.fromJson(Map<String, dynamic> json) {
    return ReturnDto(
      items: (json['items'] as List<dynamic>)
          .map((item) => BagItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      collectionPointId: json['collectionPointId'] as String,
      deviceId: json['deviceId'] as String,
    );
  }

  final List<BagItem> items;
  final String collectionPointId;
  final String deviceId;

  Map<String, dynamic> toJson() {
    return {
      'collectionPointId': collectionPointId,
      'items': items.map((item) => item.toJson()).toList(),
      'deviceId': deviceId,
    };
  }
}
