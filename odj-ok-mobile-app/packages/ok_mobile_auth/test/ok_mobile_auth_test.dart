import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';

class MockAuthUsecases extends Mock implements AuthUsecases {}

void main() {
  group('AuthCubit tests', () {
    late AuthCubit authCubit;
    late MockAuthUsecases mockAuthUsecases;

    late Failure failure;

    setUp(() {
      mockAuthUsecases = MockAuthUsecases();
      authCubit = AuthCubit(mockAuthUsecases);
      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
      );
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.loading, AuthState.authenticated] when successful',
      build: () {
        when(() => mockAuthUsecases.authenticate(any())).thenAnswer((_) async {
          return const Right(null);
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.authenticate('pl');
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.loading),
        const AuthState(authStatus: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.loading, AuthState.unauthenticated] when failed',
      build: () {
        when(() => mockAuthUsecases.authenticate(any())).thenAnswer((_) async {
          return Left(failure);
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.authenticate('pl');
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.loading),
        AuthState(authStatus: AuthStatus.unauthenticated, result: failure),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.authenticatedLoading, AuthState.unauthenticated] '
      'when signOut is successful',
      build: () {
        when(() => mockAuthUsecases.signOut()).thenAnswer((_) async {
          return const Right(null);
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.signOut();
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.authenticatedLoading),
        const AuthState(authStatus: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.authenticatedLoading, AuthState.authenticated] '
      'when signOut fails',
      build: () {
        when(() => mockAuthUsecases.signOut()).thenAnswer((_) async {
          return Left(failure);
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.signOut();
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.authenticatedLoading),
        AuthState(authStatus: AuthStatus.authenticated, result: failure),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.loading, AuthState.authenticated] when checkUser '
      'is successful and user is found',
      build: () {
        when(() => mockAuthUsecases.checkUser()).thenAnswer((_) async {
          return const Right(
            ContractorUser(
              id: 'id',
              roles: [ContractorUserRole.storeUser],
              email: 'test.email@ok.pl',
            ),
          );
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.checkUser();
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.loading),
        const AuthState(authStatus: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.loading, AuthState.unauthenticated] when checkUser '
      'is successful and user is not found',
      build: () {
        when(() => mockAuthUsecases.checkUser()).thenAnswer((_) async {
          return const Right(null);
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.checkUser();
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.loading),
        const AuthState(authStatus: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthState.loading, AuthState.unauthenticated + failure] when '
      'checkUser fails',
      build: () {
        when(() => mockAuthUsecases.checkUser()).thenAnswer((_) async {
          return Left(failure);
        });
        return authCubit;
      },
      act: (cubit) async {
        await cubit.checkUser();
      },
      expect: () => [
        const AuthState(authStatus: AuthStatus.loading),
        AuthState(authStatus: AuthStatus.unauthenticated, result: failure),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits state with cleared result when clearResult is called',
      build: () => authCubit,
      seed: () => AuthState.initial().copyWith(result: failure),
      act: (cubit) => cubit.clearResult(),
      expect: () => [AuthState.initial().copyWith()],
    );
  });
}
