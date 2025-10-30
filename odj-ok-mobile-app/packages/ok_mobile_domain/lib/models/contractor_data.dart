part of '../ok_mobile_domain.dart';

enum VoucherDisplayType {
  printable('Printed'),
  digital('Displayed'),
  none('None');

  const VoucherDisplayType(this.backendName);

  final String backendName;

  String getClosedReturnMessage() => switch (this) {
    VoucherDisplayType.printable => S.current.return_closed_print_voucher,
    VoucherDisplayType.digital => S.current.return_closed_show_voucher,
    VoucherDisplayType.none => '',
  };

  static VoucherDisplayType fromJson(String? value) {
    final normalized = value?.trim().toLowerCase();

    return switch (normalized) {
      'printed' => VoucherDisplayType.printable,
      'displayed' => VoucherDisplayType.digital,
      'none' => VoucherDisplayType.none,
      _ => VoucherDisplayType.none,
    };
  }
}

class ContractorData extends Equatable {
  const ContractorData({
    required this.id,
    required this.name,
    this.code,
    this.nip,
    this.bdoNumber,
    this.addressStreet,
    this.addressBuilding,
    this.addressApartment,
    this.addressPostalCode,
    this.addressMunicipality,
    this.voucherDisplayType,
    this.krs,
    this.court,
    this.addressCity,
    this.voucherValidityInDays,
    this.voucherAdditionalText,
  });

  factory ContractorData.fromJson(Map<String, dynamic> json) {
    return ContractorData(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      nip: json['nip'] as String?,
      bdoNumber: json['bdonumber'] as String?,
      addressCity: json['addressCity'] as String?,
      addressStreet: json['addressStreet'] as String?,
      addressBuilding: json['addressBuilding'] as String?,
      addressApartment: json['addressApartment'] as String?,
      addressPostalCode: json['addressPostalCode'] as String?,
      addressMunicipality: json['addressMunicipality'] as String?,
      voucherDisplayType: VoucherDisplayType.fromJson(
        json['voucherLooseItemOutputType'] as String?,
      ),
      krs: json['krs'] as String?,
      court: json['court'] as String?,
      voucherValidityInDays: json['voucherValidityInDays'] as int?,
      voucherAdditionalText: json['voucherAdditionalText'] as String?,
    );
  }

  final String id;
  final String name;
  final String? code;
  final String? nip;
  final String? bdoNumber;
  final String? addressCity;
  final String? addressStreet;
  final String? addressBuilding;
  final String? addressApartment;
  final String? addressPostalCode;
  final String? addressMunicipality;
  final VoucherDisplayType? voucherDisplayType;
  final String? krs;
  final String? court;
  final int? voucherValidityInDays;
  final String? voucherAdditionalText;

  ContractorData copyWith({
    String? id,
    String? name,
    String? code,
    String? nip,
    String? bdoNumber,
    String? addressCity,
    String? addressStreet,
    String? addressBuilding,
    String? addressApartment,
    String? addressPostalCode,
    String? addressMunicipality,
    VoucherDisplayType? voucherDisplayType,
    String? krs,
    String? court,
    int? voucherValidityInDays,
    String? voucherAdditionalText,
  }) {
    return ContractorData(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      nip: nip ?? this.nip,
      bdoNumber: bdoNumber ?? this.bdoNumber,
      addressCity: addressCity ?? this.addressCity,
      addressStreet: addressStreet ?? this.addressStreet,
      addressBuilding: addressBuilding ?? this.addressBuilding,
      addressApartment: addressApartment ?? this.addressApartment,
      addressPostalCode: addressPostalCode ?? this.addressPostalCode,
      addressMunicipality: addressMunicipality ?? this.addressMunicipality,
      voucherDisplayType: voucherDisplayType ?? this.voucherDisplayType,
      krs: krs ?? this.krs,
      court: court ?? this.court,
      voucherValidityInDays:
          voucherValidityInDays ?? this.voucherValidityInDays,
      voucherAdditionalText:
          voucherAdditionalText ?? this.voucherAdditionalText,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    nip,
    bdoNumber,
    addressCity,
    addressStreet,
    addressBuilding,
    addressApartment,
    addressPostalCode,
    addressMunicipality,
    voucherDisplayType,
    krs,
    court,
    voucherValidityInDays,
    voucherAdditionalText,
  ];

  @override
  String toString() {
    return 'ContractorData('
        'id: $id, '
        'name: $name, '
        'code: $code, '
        'nip: $nip, '
        'bdoNumber: $bdoNumber, '
        'addressCity: $addressCity, '
        'addressStreet: $addressStreet, '
        'addressBuilding: $addressBuilding, '
        'addressApartment: $addressApartment, '
        'addressPostalCode: $addressPostalCode, '
        'addressMunicipality: $addressMunicipality, '
        'voucherDisplayType: $voucherDisplayType, '
        'krs: $krs, '
        'court: $court, '
        'voucherValidityInDays: $voucherValidityInDays, '
        'voucherAdditionalText: $voucherAdditionalText'
        ')';
  }
}
