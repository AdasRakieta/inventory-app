import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';

class MockAuthUsecases extends Mock implements AuthUsecases {}

void main() {
  late MockAuthUsecases mockAuthUsecases;
  late UserCubit userCubit;
  late ContractorUser testUser;

  setUp(() {
    mockAuthUsecases = MockAuthUsecases();
    userCubit = UserCubit(mockAuthUsecases);
    testUser = const ContractorUser(
      id: '123',
      roles: [ContractorUserRole.storeUser],
      email: 'test.email@ok.pl',
    );
  });

  group('UserCubit', () {
    blocTest<UserCubit, UserState>(
      'emits [UserState.loaded] with user data when getUserData is called',
      build: () {
        when(() => mockAuthUsecases.userData).thenReturn(testUser);
        return userCubit;
      },
      act: (cubit) => cubit.getUserData(),
      expect: () => [UserState(status: GeneralState.loaded, user: testUser)],
    );

    blocTest<UserCubit, UserState>(
      'emits state.copyWith() when clearResult is called',
      build: () => userCubit,
      seed: () =>
          const UserState(result: Success(), status: GeneralState.loaded),
      act: (cubit) => cubit.clearResult(),
      expect: () => [userCubit.state.copyWith()],
    );
  });
}
