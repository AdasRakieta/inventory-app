part of '../../ok_mobile_data.dart';

class TokenData extends Equatable {
  const TokenData({
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpirationDate,
    required this.tokenType,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      idToken: json['id_token'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      refreshTokenExpirationDate: DateTime.parse(
        json['refresh_token_expiration_date'] as String,
      ),
      tokenType: json['token_type'] as String,
    );
  }

  factory TokenData.fromEntity(TokenDataEntity entity) {
    return TokenData(
      idToken: entity.idToken,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      refreshTokenExpirationDate: DateTime.now().add(
        Duration(seconds: entity.refreshTokenExpiresIn),
      ),
      tokenType: entity.tokenType,
    );
  }

  final String idToken;
  final String accessToken;
  final String refreshToken;
  final DateTime refreshTokenExpirationDate;
  final String tokenType;

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'refresh_token_expiration_date': refreshTokenExpirationDate
          .toIso8601String(),
      'token_type': tokenType,
    };
  }

  @override
  String toString() {
    return 'TokenData(idToken: $idToken,'
        ' accessToken: $accessToken,'
        ' refreshToken: $refreshToken,'
        ' refreshTokenExpirationDate: $refreshTokenExpirationDate,'
        ' tokenType: $tokenType)';
  }

  @override
  List<Object?> get props => [
    idToken,
    accessToken,
    refreshToken,
    refreshTokenExpirationDate,
    tokenType,
  ];
}
