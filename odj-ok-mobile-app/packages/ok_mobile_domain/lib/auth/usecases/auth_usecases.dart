part of '../../ok_mobile_domain.dart';

@LazySingleton(order: -1)
class AuthUsecases {
  final IAuthRepository _authRepository = getIt<IAuthRepository>();
  late TokenData _tokenData;
  late void Function() onLogout;

  final ValueNotifier<ContractorUser?> userNotifier = ValueNotifier(null);

  String get token => _tokenData.accessToken;
  TokenData get tokenData => _tokenData;
  ContractorUser? get userData => userNotifier.value;

  Future<Either<Failure, ContractorUser?>> authenticate(
    String languageCode, {
    bool useInApp = false,
    String? redirectResponse,
  }) async {
    Either<Failure, TokenData?> result;

    if (useInApp) {
      if (redirectResponse == null) {
        return const Left(
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: 'Missing redirectResponse for in-app login',
          ),
        );
      }

      result = await _authRepository.authenticateInApp(
        redirectResponse: redirectResponse,
      );
    } else {
      result = await _authRepository.authenticateWithNative(
        languageCode: languageCode,
      );
    }

    return result.fold(Left.new, (tokenData) async {
      if (tokenData == null) {
        return const Left(
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: 'Token is empty',
          ),
        );
      }

      _tokenData = tokenData;

      await _secureStorage.write(
        key: TokenHelper.tokenStorageKey,
        value: jsonEncode(tokenData.toJson()),
      );

      return handleLogin();
    });
  }

  Uri getAuthorizationUrl({required String languageCode}) =>
      _authRepository.getAuthorizationUrl(languageCode);

  Future<Either<Failure, void>> acceptTermsAndCondtions() async {
    final result = await getIt<ICommonRepository>().acceptTermsAndConditions();

    if (result.isLeft()) {
      return result;
    }

    final userResult = await getIt<ICommonRepository>().getCurrentUser();

    return userResult.fold(Left.new, (userData) {
      userNotifier.value = userData;
      return const Right(null);
    });
  }

  //
  // ignore: avoid_setters_without_getters
  set setOnLogout(void Function() onLogout) {
    this.onLogout = onLogout;
  }

  Future<Either<Failure, ContractorUser?>> getCurrentUser() async {
    final userResult = await getIt<ICommonRepository>().getCurrentUser();

    return userResult.fold(Left.new, (userData) {
      userNotifier.value = userData;
      return Right(userData);
    });
  }

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  FlutterSecureStorage get _secureStorage =>
      FlutterSecureStorage(aOptions: _getAndroidOptions());

  Future<Either<Failure, ContractorUser?>> checkUser() async {
    final tokenFromStorage = await _secureStorage.read(
      key: TokenHelper.tokenStorageKey,
    );

    if (tokenFromStorage != null) {
      final tokenData = TokenData.fromJson(
        jsonDecode(tokenFromStorage) as Map<String, dynamic>,
      );

      _tokenData = tokenData;

      if (_tokenData.refreshTokenExpirationDate.isBefore(DateTime.now())) {
        final signOutResult = await signOut();
        return signOutResult.fold(Left.new, (_) => const Right(null));
      } else {
        if (Jwt.isExpired(_tokenData.accessToken)) {
          final refreshTokenResult = await refreshToken();
          return refreshTokenResult.fold(
            (failure) async => Left(failure),
            (_) async => handleLogin(),
          );
        } else {
          return handleLogin();
        }
      }
    } else {
      return const Right(null);
    }
  }

  Future<Either<Failure, ContractorUser?>> handleLogin() async {
    final loginResult = await getCurrentUser();
    return loginResult.fold(Left.new, Right.new);
  }

  Future<Either<Failure, Unit?>> signOut() async {
    final result = await _authRepository.signOut(idToken: _tokenData.idToken);

    return result.fold(Left.new, (_) async {
      await _secureStorage.delete(key: TokenHelper.tokenStorageKey);
      if (!isTestExecution) {
        await DeviceConfigDatasource().clearMobileDeviceConfigCache();
      }
      await PreferencesHelper().clearMasterDataPrefs();
      userNotifier.value = null;
      return const Right(null);
    });
  }

  Future<Either<Failure, TokenData>> refreshToken() async {
    final result = await _authRepository.refreshToken(
      refreshToken: _tokenData.refreshToken,
    );

    return await result.fold(
      (failure) async {
        if (failure.type == FailureType.tokenRefreshFailed) {
          await signOut();
          onLogout();
        }
        return Left(failure);
      },
      (tokenData) async {
        _tokenData = tokenData;
        await _secureStorage.write(
          key: TokenHelper.tokenStorageKey,
          value: jsonEncode(tokenData.toJson()),
        );
        return Right(tokenData);
      },
    );
  }
}
