part of '../../ok_mobile_auth.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  authenticatedLoading,
}

class AuthState extends Equatable {
  const AuthState({required this.authStatus, this.result});

  factory AuthState.initial() =>
      const AuthState(authStatus: AuthStatus.initial);

  final AuthStatus authStatus;
  final Result? result;

  AuthState copyWith({AuthStatus? authStatus, Result? result}) {
    return AuthState(authStatus: authStatus ?? this.authStatus, result: result);
  }

  @override
  List<Object?> get props => [authStatus, result];
}
