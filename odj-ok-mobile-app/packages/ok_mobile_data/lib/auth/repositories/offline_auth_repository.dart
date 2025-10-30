part of '../../ok_mobile_data.dart';

@Environment(AppEnvironment.offline)
@Injectable(as: IAuthRepository)
class OfflineAuthRepository extends IAuthRepository {
  OfflineAuthRepository();

  @override
  Future<Either<Failure, TokenData?>> authenticateWithNative({
    required String languageCode,
  }) async {
    return Right(
      TokenData(
        idToken: '',
        accessToken: '',
        refreshToken: '',
        refreshTokenExpirationDate: DateTime.now(),
        tokenType: '',
      ),
    );
  }

  @override
  Future<Either<Failure, TokenData?>> authenticateInApp({
    required String redirectResponse,
  }) async {
    return Right(
      TokenData(
        idToken: '',
        accessToken: '',
        refreshToken: '',
        refreshTokenExpirationDate: DateTime.now(),
        tokenType: '',
      ),
    );
  }

  @override
  Future<Either<Failure, Unit?>> resetPassword({required String login}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Unit?>> signOut({required String idToken}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, TokenData>> refreshToken({
    required String refreshToken,
  }) async {
    return Right(
      TokenData(
        idToken: '',
        accessToken: '',
        refreshToken: '',
        refreshTokenExpirationDate: DateTime.now().add(
          const Duration(days: 365),
        ),
        tokenType: '',
      ),
    );
  }

  @override
  Uri getAuthorizationUrl(String languageCode) {
    return Uri();
  }
}
