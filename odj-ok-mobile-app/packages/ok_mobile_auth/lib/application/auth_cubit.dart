part of '../../ok_mobile_auth.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authUsecases) : super(AuthState.initial()) {
    _authUsecases.setOnLogout = () {
      emit(
        state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          result: Failure(
            type: FailureType.tokenRefreshFailed,
            severity: FailureSeverity.warning,
            message: S.current.session_expired,
          ),
        ),
      );
    };
  }

  final AuthUsecases _authUsecases;

  Future<void> authenticate(String languageCode) async {
    emit(const AuthState(authStatus: AuthStatus.loading));

    final result = await _authUsecases.authenticate(languageCode);

    result.fold(
      (failure) {
        emit(
          AuthState(authStatus: AuthStatus.unauthenticated, result: failure),
        );
      },
      (_) {
        emit(const AuthState(authStatus: AuthStatus.authenticated));
      },
    );
  }

  Future<void> authenticateInApp({
    required String languageCode,
    required String redirectReponse,
  }) async {
    emit(const AuthState(authStatus: AuthStatus.loading));

    final result = await _authUsecases.authenticate(
      languageCode,
      useInApp: true,
      redirectResponse: redirectReponse,
    );

    result.fold(
      (failure) {
        emit(
          AuthState(authStatus: AuthStatus.unauthenticated, result: failure),
        );
      },
      (_) {
        emit(const AuthState(authStatus: AuthStatus.authenticated));
      },
    );
  }

  Uri getAuthenticationUri({required String languageCode}) =>
      _authUsecases.getAuthorizationUrl(languageCode: languageCode);

  Future<bool> signOut() async {
    emit(const AuthState(authStatus: AuthStatus.authenticatedLoading));

    final result = await _authUsecases.signOut();

    return result.fold(
      (failure) {
        emit(AuthState(authStatus: AuthStatus.authenticated, result: failure));
        return false;
      },
      (_) {
        emit(const AuthState(authStatus: AuthStatus.unauthenticated));
        return true;
      },
    );
  }

  Future<void> checkUser() async {
    emit(const AuthState(authStatus: AuthStatus.loading));

    final result = await _authUsecases.checkUser();

    result.fold(
      (failure) {
        emit(
          AuthState(authStatus: AuthStatus.unauthenticated, result: failure),
        );
      },
      (result) {
        if (result != null) {
          emit(const AuthState(authStatus: AuthStatus.authenticated));
        } else {
          emit(const AuthState(authStatus: AuthStatus.unauthenticated));
        }
      },
    );
  }

  void clearResult() {
    emit(state.copyWith());
  }
}
