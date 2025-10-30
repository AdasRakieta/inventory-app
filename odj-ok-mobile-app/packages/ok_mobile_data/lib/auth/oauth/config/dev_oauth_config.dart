part of '../../../ok_mobile_data.dart';

@Injectable(as: IOauthConfig)
@Environment(AppEnvironment.dev)
class DevOauthConfig implements IOauthConfig {
  @override
  Uri get authorizationEndpoint => Uri.parse(
    'https://b2cokdev.b2clogin.com/b2cokdev.onmicrosoft.com/oauth2/v2.0/authorize?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get tokenEndpoint => Uri.parse(
    'https://b2cokdev.b2clogin.com/b2cokdev.onmicrosoft.com/oauth2/v2.0/token?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get logoutEndpoint => Uri.parse(
    'https://b2cokdev.b2clogin.com/b2cokdev.onmicrosoft.com/oauth2/v2.0/logout?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get siamLogoutEndpoint => Uri.parse(
    'https://federation-q.auth.schwarz/nidp/oauth/v1/nam/end_session',
  );

  @override
  String get clientId => 'd24bff80-5c1c-482c-acb8-51d4415b8af3';

  @override
  Uri get redirect =>
      Uri.parse('msauth://com.ok.mobile.dev/lvGC0B4SWYU8tNPHg/bdMjQinZQ=');

  @override
  List<String> get scopes => [
    'openid',
    'offline_access',
    'https://b2cokdev.onmicrosoft.com/190de8b3-1f2d-4c5f-98ae-86a8cac80eed/access_as_user',
  ];
}
