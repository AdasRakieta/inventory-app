part of '../../ok_mobile_domain.dart';

abstract class IAuthRepository {
  Future<Either<Failure, TokenData?>> authenticateWithNative({
    required String languageCode,
  });
  Future<Either<Failure, TokenData?>> authenticateInApp({
    required String redirectResponse,
  });

  Uri getAuthorizationUrl(String languageCode);

  Future<Either<Failure, Unit?>> resetPassword({required String login});
  Future<Either<Failure, Unit?>> signOut({required String idToken});
  Future<Either<Failure, TokenData>> refreshToken({
    required String refreshToken,
  });
}
