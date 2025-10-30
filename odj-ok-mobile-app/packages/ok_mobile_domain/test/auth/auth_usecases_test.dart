import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock classes
class MockAuthRepository extends Mock implements IAuthRepository {}

class MockCommonRepository extends Mock implements ICommonRepository {}

final GetIt getIt = GetIt.instance;

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockCommonRepository mockCommonRepository;
  late AuthUsecases authUsecases;
  const validJwtToken =
      'eyJhbGciOiJSUzI1NiIsImtpZCI6ImFhUXhiY1hMNW52anczb2dEZW9ITENRWTFGc3dWdUtR'
      'a002ai0xZmJhV3ciLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJmMjFhZDRmZC0zMDU1LTQxYTQtO'
      'TBhMy0xMGRkMzQ0OTI2NjciLCJpc3MiOiJodHRwczovL2IyY29rdHN0LmIyY2xvZ2luLmNvb'
      'S8xZTA3ZDY0Yi05NWVhLTQwZTAtYmUzMy05MWUxZmQwZjQ1MTkvdjIuMC8iLCJleHAiOjE3N'
      'DE4Nzg2NjQsIm5iZiI6MTc0MTg3NTA2NCwic3ViIjoiNzA5MmQ4NzUtZDYwMS00OGI3LTk4Y'
      '2EtYmQ4MTU1YTNhNDIxIiwib2lkIjoiNzA5MmQ4NzUtZDYwMS00OGI3LTk4Y2EtYmQ4MTU1Y'
      'TNhNDIxIiwibmFtZSI6InRlc3QtYjJjLW1vYmlsZS1hcHAiLCJ0aWQiOiIxZTA3ZDY0Yi05N'
      'WVhLTQwZTAtYmUzMy05MWUxZmQwZjQ1MTkiLCJzY3AiOiJhY2Nlc3NfYXNfdXNlciIsImF6c'
      'CI6ImU0MmQwNTA4LTZjNmEtNDUxZi1iMTkyLWM0MDQ4MzQ5MTUxMSIsInZlciI6IjEuMCIsI'
      'mlhdCI6MTc0MTg3NTA2NH0.OyWZpdtPkrbhjieuTq-CBHXB32WbQIZsX4fe-SOc8Ik9VeDkR'
      'raaIE7V8uEX6WuXz0SxheTJs87Wc-MId-UilEeEyd6-DuKmH-laGPW4UjzsQArJ5Qn0WzEqJ'
      'E-npayFuji_WE_va8OQuDKBTh4g6aAfUIqtL5O8aLa_G8LQqluoXOeeQ5ak8f_QecDn8DDgb'
      'LBpbxJu05XeIN1-nGwI74y0_cQHPwt5c_zRyivfhtCacwMNAZPhsU16tK3N-pVwdh4ZYC21B'
      'IUi8IRd-RfLSqPvNR7Fgd4RHzuU5FMpfE9wBYZgs54l6POpCAhTxlJWludOXNtRtFuinRMV0'
      'vWAIw';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockAuthRepository = MockAuthRepository();
    mockCommonRepository = MockCommonRepository();
    getIt
      ..registerSingleton<IAuthRepository>(mockAuthRepository)
      ..registerSingleton<ICommonRepository>(mockCommonRepository);
    authUsecases = AuthUsecases();
  });

  group('authenticate', () {
    test('should return ContractorUser on successful authentication', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenData = TokenData(
        accessToken: validJwtToken,
        refreshToken: validJwtToken,
        idToken: validJwtToken,
        refreshTokenExpirationDate: DateTime.now().add(const Duration(days: 1)),
        tokenType: 'Bearer',
      );

      when(
        () => mockAuthRepository.authenticateWithNative(
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => Right(tokenData));
      when(() => mockCommonRepository.getCurrentUser()).thenAnswer(
        (_) async => const Right(
          ContractorUser(
            id: '1',
            roles: [ContractorUserRole.storeUser],
            email: 'test.email@ok.pl',
          ),
        ),
      );

      final result = await authUsecases.authenticate('pl');

      final tokenFromStorage = await const FlutterSecureStorage().read(
        key: TokenHelper.tokenStorageKey,
      );

      final tokenDataFromStorage = TokenData.fromJson(
        jsonDecode(tokenFromStorage!) as Map<String, dynamic>,
      );

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), isA<ContractorUser>());
      expect(tokenDataFromStorage, tokenData);
    });

    test('should return Failure on failed authentication', () async {
      FlutterSecureStorage.setMockInitialValues({});

      const failure = Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
      );

      when(
        () => mockAuthRepository.authenticateWithNative(
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await authUsecases.authenticate('pl');

      expect(result.isLeft(), true);
      expect(result, const Left<Failure, ContractorUser?>(failure));
    });
  });

  group('checkUser', () {
    test(
      'should return ContractorUser if token is valid and not expired',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          TokenHelper.tokenStorageKey: jsonEncode(
            TokenData(
              accessToken: validJwtToken,
              refreshToken: validJwtToken,
              idToken: validJwtToken,
              refreshTokenExpirationDate: DateTime.now().add(
                const Duration(days: 1),
              ),
              tokenType: 'Bearer',
            ).toJson(),
          ),
        });

        when(() => mockCommonRepository.getCurrentUser()).thenAnswer(
          (_) async => const Right(
            ContractorUser(
              id: '1',
              roles: [ContractorUserRole.storeUser],
              email: 'test.email@ok.pl',
            ),
          ),
        );

        when(
          () => mockAuthRepository.refreshToken(
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer(
          (_) async => Right(
            TokenData(
              accessToken: validJwtToken,
              refreshToken: validJwtToken,
              idToken: validJwtToken,
              refreshTokenExpirationDate: DateTime.now().add(
                const Duration(days: 1),
              ),
              tokenType: 'Bearer',
            ),
          ),
        );

        final result = await authUsecases.checkUser();

        expect(result.isRight(), true);
        expect(result.getOrElse(() => null), isA<ContractorUser>());
      },
    );

    test('should return null if no token is found in storage', () async {
      FlutterSecureStorage.setMockInitialValues({});

      final result = await authUsecases.checkUser();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), null);
    });

    test(
      'should sign out and return null if refresh token is expired',
      () async {
        SharedPreferences.setMockInitialValues({});
        FlutterSecureStorage.setMockInitialValues({
          TokenHelper.tokenStorageKey: jsonEncode(
            TokenData(
              accessToken: validJwtToken,
              refreshToken: validJwtToken,
              idToken: validJwtToken,
              refreshTokenExpirationDate: DateTime.now().subtract(
                const Duration(days: 1),
              ),
              tokenType: 'Bearer',
            ).toJson(),
          ),
        });

        when(
          () => mockAuthRepository.signOut(idToken: any(named: 'idToken')),
        ).thenAnswer((_) async => const Right(unit));

        final result = await authUsecases.checkUser();

        expect(result.isRight(), true);
        expect(result.getOrElse(() => null), null);
      },
    );

    test('should refresh token if access token is expired', () async {
      FlutterSecureStorage.setMockInitialValues({
        TokenHelper.tokenStorageKey: jsonEncode(
          TokenData(
            accessToken: validJwtToken,
            refreshToken: validJwtToken,
            idToken: validJwtToken,
            refreshTokenExpirationDate: DateTime.now().add(
              const Duration(days: 1),
            ),
            tokenType: 'Bearer',
          ).toJson(),
        ),
      });

      final newTokenData = TokenData(
        accessToken: validJwtToken,
        refreshToken: validJwtToken,
        idToken: validJwtToken,
        refreshTokenExpirationDate: DateTime.now().add(const Duration(days: 1)),
        tokenType: 'Bearer',
      );

      when(
        () => mockAuthRepository.refreshToken(
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async => Right(newTokenData));

      when(() => mockCommonRepository.getCurrentUser()).thenAnswer(
        (_) async => const Right(
          ContractorUser(
            id: '1',
            roles: [ContractorUserRole.storeUser],
            email: 'test.email@ok.pl',
          ),
        ),
      );

      final result = await authUsecases.checkUser();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => null), isA<ContractorUser>());
    });
  });
}
