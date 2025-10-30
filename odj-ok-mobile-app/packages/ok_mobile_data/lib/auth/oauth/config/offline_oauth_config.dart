part of '../../../ok_mobile_data.dart';

@Injectable(as: IOauthConfig)
@Environment(AppEnvironment.offline)
class OfflineOauthConfig implements IOauthConfig {
  @override
  Uri get authorizationEndpoint => Uri.parse('');

  @override
  Uri get tokenEndpoint => Uri.parse('');

  @override
  Uri get logoutEndpoint => Uri.parse('');

  @override
  Uri get siamLogoutEndpoint => Uri.parse('');

  @override
  String get clientId => '';

  @override
  Uri get redirect => Uri.parse('');

  @override
  List<String> get scopes => [];
}
