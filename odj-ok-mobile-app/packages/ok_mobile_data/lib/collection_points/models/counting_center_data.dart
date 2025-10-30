part of '../../ok_mobile_data.dart';

class CountingCenterData extends Equatable {
  const CountingCenterData({
    required this.id,
    required this.name,
    required this.code,
    required this.nip,
    required this.addressPostalCode,
    required this.addressStreet,
    required this.addressBuilding,
    required this.addressCity,
    this.addressApartment,
    this.addressMunicipality,
  });

  factory CountingCenterData.fromJson(Map<String, dynamic> json) {
    return CountingCenterData(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      nip: json['nip'] as String,
      addressPostalCode: json['addressPostalCode'] as String,
      addressStreet: json['addressStreet'] as String,
      addressBuilding: json['addressBuilding'] as String,
      addressApartment: json['addressApartment'] as String?,
      addressCity: json['addressCity'] as String,
      addressMunicipality: json['addressMunicipality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'nip': nip,
      'addressPostalCode': addressPostalCode,
      'addressStreet': addressStreet,
      'addressBuilding': addressBuilding,
      'addressApartment': addressApartment,
      'addressCity': addressCity,
      'addressMunicipality': addressMunicipality,
    };
  }

  final String id;
  final String name;
  final String code;
  final String nip;
  final String addressPostalCode;
  final String addressStreet;
  final String addressBuilding;
  final String? addressApartment;
  final String addressCity;
  final String? addressMunicipality;

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
  ];
}
