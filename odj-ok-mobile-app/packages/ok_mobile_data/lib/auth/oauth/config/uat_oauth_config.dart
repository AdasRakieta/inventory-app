part of '../../../ok_mobile_data.dart';

@Injectable(as: IOauthConfig)
@Environment(AppEnvironment.uat)
class UatOauthConfig implements IOauthConfig {
  @override
  Uri get authorizationEndpoint => Uri.parse(
    'https://b2cokuat.b2clogin.com/b2cokuat.onmicrosoft.com/oauth2/v2.0/authorize?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get tokenEndpoint => Uri.parse(
    'https://b2cokuat.b2clogin.com/b2cokuat.onmicrosoft.com/oauth2/v2.0/token?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get logoutEndpoint => Uri.parse(
    'https://b2cokuat.b2clogin.com/b2cokuat.onmicrosoft.com/oauth2/v2.0/logout?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get siamLogoutEndpoint => Uri.parse(
    'https://federation.auth.schwarz/nidp/oauth/v1/nam/end_session',
  );

  @override
  String get clientId => '51cb11b2-a444-45fb-9493-2d8956dc8946';

  @override
  Uri get redirect =>
      Uri.parse('msauth://com.ok.mobile.uat/lvGC0B4SWYU8tNPHg/bdMjQinZQ=');

  @override
  List<String> get scopes => [
    'openid',
    'offline_access',
    'https://b2cokuat.onmicrosoft.com/d77f6e9e-7276-4a04-8d1b-6851d22be6a4/access_as_user',
  ];
}
