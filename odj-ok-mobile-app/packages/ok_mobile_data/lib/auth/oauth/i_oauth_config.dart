part of '../../ok_mobile_data.dart';

abstract class IOauthConfig {
  Uri get authorizationEndpoint;
  Uri get tokenEndpoint;
  Uri get logoutEndpoint;
  Uri get siamLogoutEndpoint;
  String get clientId;
  Uri get redirect;
  List<String> get scopes;
}
