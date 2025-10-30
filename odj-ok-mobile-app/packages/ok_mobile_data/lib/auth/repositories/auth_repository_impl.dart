part of '../../ok_mobile_data.dart';

@Injectable(
  as: IAuthRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class AuthRepositoryImpl extends IAuthRepository {
  AuthRepositoryImpl(this._oauthClient);

  final OauthClient _oauthClient;

  @override
  Future<Either<Failure, TokenData?>> authenticateWithNative({
    required String languageCode,
  }) async {
    return _oauthClient.authenticateNative(languageCode: languageCode);
  }

  @override
  Future<Either<Failure, TokenData?>> authenticateInApp({
    required String redirectResponse,
  }) async {
    return _oauthClient.authenticateInApp(redirectResponse: redirectResponse);
  }

  @override
  Uri getAuthorizationUrl(String languageCode) {
    return _oauthClient.getAuthorizationUrl(languageCode);
  }

  @override
  Future<Either<Failure, Unit?>> resetPassword({required String login}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> signOut({required String idToken}) async {
    return _oauthClient.signOut(idToken: idToken);
  }

  @override
  Future<Either<Failure, TokenData>> refreshToken({
    required String refreshToken,
  }) {
    return _oauthClient.refreshToken(refreshToken: refreshToken);
  }
}
