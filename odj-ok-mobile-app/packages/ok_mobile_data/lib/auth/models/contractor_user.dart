part of '../../../../ok_mobile_data.dart';

enum ContractorUserRole {
  invalid(jsonKey: 'Invalid'),
  administrator(jsonKey: 'Administrator'),
  keyUser(jsonKey: 'KeyUser'),
  regularUser(jsonKey: 'RegularUser'),
  reader(jsonKey: 'Reader'),
  support(jsonKey: 'Support'),
  producer(jsonKey: 'Producer'),
  storeUser(jsonKey: 'StoreUser'),
  countingCenterUser(jsonKey: 'CountingCenterUser'),
  mobileSupport(jsonKey: 'MobileSupport');

  const ContractorUserRole({required this.jsonKey});

  factory ContractorUserRole.fromJson(String jsonKey) {
    return ContractorUserRole.values.firstWhere(
      (role) => role.jsonKey == jsonKey,
      orElse: () => ContractorUserRole.invalid,
    );
  }

  final String jsonKey;
}

class ContractorUser extends Equatable {
  const ContractorUser({
    required this.id,
    required this.roles,
    this.name,
    this.surname,
    this.email,
    this.personalNumber,
    this.contractorData,
    this.hasAcceptedTerms = false,
  });

  factory ContractorUser.fromJson(Map<String, dynamic> json) {
    return ContractorUser(
      id: json['id'] as String,
      roles: List<String>.from(json['roles'] as Iterable<dynamic>).map((
        jsonKey,
      ) {
        return ContractorUserRole.fromJson(jsonKey);
      }).toList(),
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      email: json['email'] as String?,
      personalNumber: json['personalNumber'] as String?,
      contractorData: json['contractor'] != null
          ? ContractorData.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      hasAcceptedTerms: json['hasAcceptedTerms'] as bool? ?? false,
    );
  }

  final String id;
  final List<ContractorUserRole> roles;
  final String? name;
  final String? surname;
  final String? email;
  final String? personalNumber;
  final ContractorData? contractorData;
  final bool hasAcceptedTerms;

  @override
  List<Object?> get props => [
    id,
    roles,
    name,
    surname,
    email,
    personalNumber,
    hasAcceptedTerms,
  ];

  bool get isStoreUser => roles.contains(ContractorUserRole.storeUser);
  bool get isCountingCenterUser =>
      roles.contains(ContractorUserRole.countingCenterUser);
  bool get isSupportUser => roles.contains(ContractorUserRole.mobileSupport);

  String get identity => email?.split('@').first ?? personalNumber ?? '';

  ContractorUser copyWith({
    String? id,
    String? contractorId,
    List<ContractorUserRole>? roles,
    String? name,
    String? surname,
    String? email,
    String? personalNumber,
    bool? hasAcceptedTerms,
  }) {
    return ContractorUser(
      id: id ?? this.id,
      roles: roles ?? this.roles,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      personalNumber: personalNumber ?? this.personalNumber,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
    );
  }
}
