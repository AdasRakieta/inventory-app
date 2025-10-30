part of '../../../ok_mobile_data.dart';

@Injectable(as: IOauthConfig)
@Environment(AppEnvironment.prd)
class OauthConfig implements IOauthConfig {
  @override
  Uri get authorizationEndpoint => Uri.parse(
    'https://b2cokprd.b2clogin.com/b2cokprd.onmicrosoft.com/oauth2/v2.0/authorize?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get tokenEndpoint => Uri.parse(
    'https://b2cokprd.b2clogin.com/b2cokprd.onmicrosoft.com/oauth2/v2.0/token?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get logoutEndpoint => Uri.parse(
    'https://b2cokprd.b2clogin.com/b2cokprd.onmicrosoft.com/oauth2/v2.0/logout?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get siamLogoutEndpoint => Uri.parse(
    'https://federation.auth.schwarz/nidp/oauth/v1/nam/end_session',
  );

  @override
  String get clientId => '4e595908-d670-4f27-8130-fc42667dc43c';

  @override
  Uri get redirect =>
      Uri.parse('msauth://com.ok.mobile/lvGC0B4SWYU8tNPHg/bdMjQinZQ=');

  @override
  List<String> get scopes => [
    'openid',
    'offline_access',
    'https://b2cokprd.onmicrosoft.com/38b13dc8-e897-4f30-a555-d1a5acdbc37e/access_as_user',
  ];
}
