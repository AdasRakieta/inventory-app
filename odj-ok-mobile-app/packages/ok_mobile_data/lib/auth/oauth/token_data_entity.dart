part of '../../ok_mobile_data.dart';

class TokenDataEntity {
  TokenDataEntity({
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiresIn,
    required this.tokenType,
  });

  factory TokenDataEntity.fromJson(Map<String, dynamic> json) {
    return TokenDataEntity(
      idToken: json['id_token'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      refreshTokenExpiresIn: json['refresh_token_expires_in'] as int,
      tokenType: json['token_type'] as String,
    );
  }

  final String idToken;
  final String accessToken;
  final String refreshToken;
  final int refreshTokenExpiresIn;
  final String tokenType;

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'refresh_token_expires_in': refreshTokenExpiresIn,
      'token_type': tokenType,
    };
  }
}
