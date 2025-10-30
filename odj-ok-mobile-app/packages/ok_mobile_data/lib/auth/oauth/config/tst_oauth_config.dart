part of '../../../ok_mobile_data.dart';

@Injectable(as: IOauthConfig)
@Environment(AppEnvironment.tst)
class TstOauthConfig implements IOauthConfig {
  @override
  Uri get authorizationEndpoint => Uri.parse(
    'https://b2coktst.b2clogin.com/b2coktst.onmicrosoft.com/oauth2/v2.0/authorize?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get tokenEndpoint => Uri.parse(
    'https://b2coktst.b2clogin.com/b2coktst.onmicrosoft.com/oauth2/v2.0/token?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get logoutEndpoint => Uri.parse(
    'https://b2coktst.b2clogin.com/b2coktst.onmicrosoft.com/oauth2/v2.0/logout?p=b2c_1a_signuporsignin',
  );

  @override
  Uri get siamLogoutEndpoint => Uri.parse(
    'https://federation-q.auth.schwarz/nidp/oauth/v1/nam/end_session',
  );

  @override
  String get clientId => 'e42d0508-6c6a-451f-b192-c40483491511';

  @override
  Uri get redirect =>
      Uri.parse('msauth://com.ok.mobile.stage/lvGC0B4SWYU8tNPHg/bdMjQinZQ=');

  @override
  List<String> get scopes => [
    'openid',
    'offline_access',
    'https://b2coktst.onmicrosoft.com/f21ad4fd-3055-41a4-90a3-10dd34492667/access_as_user',
  ];
}
