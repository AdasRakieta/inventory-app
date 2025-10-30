part of '../../ok_mobile_data.dart';

class CollectionPointData extends Equatable {
  const CollectionPointData({
    required this.id,
    required this.segregatesItems,
    required this.code,
    this.name,
    this.nip,
    this.addressPostalCode,
    this.addressStreet,
    this.addressBuilding,
    this.addressApartment,
    this.addressCity,
    this.addressMunicipality,
    this.countingCenter,
    this.contractor,
    this.collectedPackagingType,
  });

  factory CollectionPointData.fromJson(Map<String, dynamic> json) {
    return CollectionPointData(
      id: json['id'] as String,
      name: json['name'] as String?,
      code: json['code'] as String,
      nip: json['nip'] as String?,
      addressPostalCode: json['addressPostalCode'] as String?,
      addressStreet: json['addressStreet'] as String?,
      addressBuilding: json['addressBuilding'] as String?,
      addressApartment: json['addressApartment'] as String?,
      addressCity: json['addressCity'] as String?,
      addressMunicipality: json['addressMunicipality'] as String?,
      segregatesItems: json['segregatesItems'] as bool?,
      countingCenter: json['countingCenter'] != null
          ? CountingCenterData.fromJson(
              json['countingCenter'] as Map<String, dynamic>,
            )
          : null,
      contractor: json['contractor'] != null
          ? ContractorData.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      collectedPackagingType: CollectedPackagingTypeEnum.fromJson(
        json['collectedPackagingTypeManual'] as String?,
      ),
    );
  }

  final String id;
  final String code;
  final String? name;
  final String? nip;
  final bool? segregatesItems;
  final String? addressCity;
  final String? addressStreet;
  final String? addressBuilding;
  final String? addressApartment;
  final String? addressPostalCode;
  final String? addressMunicipality;
  final CountingCenterData? countingCenter;
  final ContractorData? contractor;
  final CollectedPackagingTypeEnum? collectedPackagingType;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    nip,
    addressPostalCode,
    addressStreet,
    addressBuilding,
    addressApartment,
    addressCity,
    addressMunicipality,
    segregatesItems,
    countingCenter,
    contractor,
    collectedPackagingType,
  ];
}
