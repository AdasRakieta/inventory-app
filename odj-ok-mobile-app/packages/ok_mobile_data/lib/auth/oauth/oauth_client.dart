part of '../../ok_mobile_data.dart';

@injectable
class OauthClient {
  OauthClient(this.oauthConfig);

  final IOauthConfig oauthConfig;
  PkcePair? _currentPkce;

  Uri getAuthorizationUrl(String languageCode) {
    _currentPkce ??= PkcePair.generate();
    final uri = oauthConfig.authorizationEndpoint.replace(
      queryParameters: {
        ...oauthConfig.authorizationEndpoint.queryParameters,
        'client_id': oauthConfig.clientId,
        'response_type': 'code',
        'redirect_uri': oauthConfig.redirect.toString(),
        'scope': oauthConfig.scopes.join(' '),
        'prompt': 'login',
        'response_mode': 'query',
        'code_challenge': _currentPkce!.codeChallenge,
        'code_challenge_method': 'S256',
        'ui_locales': languageCode,
      },
    );
    return uri;
  }

  String? _getCodeVerifier() {
    final verifier = _currentPkce?.codeVerifier;
    _currentPkce = null;
    return verifier;
  }

  Future<Either<Failure, TokenData>> authenticateNative({
    required String languageCode,
  }) async {
    final httpClient = getIt<AppHttpClient>().httpClient();
    try {
      final authorizationUrl = getAuthorizationUrl(languageCode);

      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: 'msauth',
        options: FlutterWebAuth2Options(
          intentFlags: ephemeralIntentFlags,
          preferEphemeral: Platform.isIOS,
        ),
      );

      final authorizationCode = Uri.parse(result).queryParameters['code'];
      if (authorizationCode == null) {
        return const Left(
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: 'Missing authorization code',
          ),
        );
      }

      final codeVerifier = _getCodeVerifier();

      return _exchangeToken(authorizationCode, codeVerifier, httpClient);
    } catch (e, stack) {
      return Left(ExceptionHelper.handleGeneralException(e, stackTrace: stack));
    }
  }

  Future<Either<Failure, TokenData>> authenticateInApp({
    required String redirectResponse,
  }) async {
    final httpClient = getIt<AppHttpClient>().httpClient();
    try {
      final uri = Uri.parse(redirectResponse);
      final code = uri.queryParameters['code'];
      if (code == null) {
        return const Left(
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: 'Missing authorization code',
          ),
        );
      }

      final codeVerifier = _getCodeVerifier();

      return _exchangeToken(code, codeVerifier, httpClient);
    } catch (e, stack) {
      return Left(ExceptionHelper.handleGeneralException(e, stackTrace: stack));
    }
  }

  Future<Either<Failure, TokenData>> _exchangeToken(
    String authorizationCode,
    String? codeVerifier,
    http.Client httpClient,
  ) async {
    final body = {
      'client_id': oauthConfig.clientId,
      'grant_type': 'authorization_code',
      'code': authorizationCode,
      'redirect_uri': oauthConfig.redirect.toString(),
    };
    if (codeVerifier != null) {
      body['code_verifier'] = codeVerifier;
    }

    final tokenResponse = await httpClient.post(
      oauthConfig.tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (tokenResponse.statusCode != 200) {
      return Left(
        Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: 'Error: ${tokenResponse.statusCode} - ${tokenResponse.body}',
        ),
      );
    }

    final tokenMap = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final tokenEntity = TokenDataEntity.fromJson(tokenMap);
    final token = TokenData.fromEntity(tokenEntity);

    return Right(token);
  }

  Future<Either<Failure, TokenData>> refreshToken({
    required String refreshToken,
  }) async {
    final httpClient = getIt<AppHttpClient>().httpClient();

    try {
      final tokenResponse = await httpClient.post(
        oauthConfig.tokenEndpoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': oauthConfig.clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'redirect_uri': oauthConfig.redirect.toString(),
        },
      );

      if (tokenResponse.statusCode == 200) {
        final tokenMap = jsonDecode(tokenResponse.body) as Map<String, dynamic>;

        final tokenEntityDeserialised = TokenDataEntity.fromJson(tokenMap);

        final tokenDeserialised = TokenData.fromEntity(tokenEntityDeserialised);

        return Right(tokenDeserialised);
      } else {
        return const Left(
          Failure(
            type: FailureType.tokenRefreshFailed,
            severity: FailureSeverity.error,
            message: 'Token refresh failed',
          ),
        );
      }
    } on SocketException catch (error, stack) {
      log('No internet connection', stackTrace: stack);
      return Left(NoInternetFailure());
    } catch (error, stack) {
      log(error.toString(), stackTrace: stack);
      return Left(
        ExceptionHelper.handleGeneralException(error, stackTrace: stack),
      );
    }
  }

  Future<Either<Failure, Unit?>> signOut({required String idToken}) async {
    final httpClient = getIt<AppHttpClient>().httpClient();

    http.Response? control;
    String? idpSource;

    try {
      final parsedIdToken = Jwt.parseJwt(idToken);
      idpSource = parsedIdToken['userSourceIdentityProvider'] as String?;
      final configType = getIt<AppConfigProvider>().configType;

      switch ((idpSource, configType)) {
        case ('SIAM', _):
          control = await httpClient.get(oauthConfig.siamLogoutEndpoint);
          return const Right(null);

        case (_, ConfigType.lidl):
          await httpClient.post(
            oauthConfig.logoutEndpoint,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'id_token_hint': idToken},
          );
          return const Right(null);

        default:
          final logoutResult = await FlutterWebAuth2.authenticate(
            url: oauthConfig.logoutEndpoint
                .replace(
                  queryParameters: {
                    ...oauthConfig.logoutEndpoint.queryParameters,
                    'id_token_hint': idToken,
                    'post_logout_redirect_uri': oauthConfig.redirect.toString(),
                  },
                )
                .toString(),
            callbackUrlScheme: 'msauth',
            options: FlutterWebAuth2Options(
              intentFlags: ephemeralIntentFlags,
              preferEphemeral: Platform.isIOS,
            ),
          );

          if (logoutResult == oauthConfig.redirect.toString()) {
            return const Right(null);
          }

          return const Left(
            Failure(
              type: FailureType.general,
              severity: FailureSeverity.error,
              message: 'Sign out failed',
            ),
          );
      }
    } on SocketException catch (error, stack) {
      log('No internet connection', stackTrace: stack);
      LoggerService().trackError(
        error,
        stackTrace: stack,
        properties: {
          'controlStatusCode': control?.statusCode ?? 'No status code',
          'idpSource': idpSource ?? 'No IDP source',
        },
      );
      return Left(NoInternetFailure());
    } on PlatformException catch (error, stack) {
      switch (error.code) {
        case 'CANCELED':
          if (control != null && control.statusCode == 200) {
            return const Right(null);
          }
          LoggerService().trackError(
            error,
            stackTrace: stack,
            properties: {
              'controlStatusCode': control?.statusCode ?? 'No status code',
              'idpSource': idpSource ?? 'No IDP source',
            },
          );
          return Left(
            Failure(
              type: FailureType.userCancelledAuth,
              severity: FailureSeverity.warning,
              message: S.current.logout_cancelled,
            ),
          );
        default:
          log(error.toString(), stackTrace: stack);
          LoggerService().trackError(
            error,
            stackTrace: stack,
            properties: {'idpSource': idpSource ?? 'No IDP source'},
          );
          return Left(
            Failure(
              type: FailureType.general,
              severity: FailureSeverity.error,
              message: error.message,
            ),
          );
      }
    } catch (error, stack) {
      log(error.toString(), stackTrace: stack);
      return Left(
        ExceptionHelper.handleGeneralException(error, stackTrace: stack),
      );
    }
  }
}
