part of '../../ok_mobile_auth.dart';

@injectable
class UserCubit extends Cubit<UserState> implements ISnackBarCubit {
  UserCubit(this._authUsecases) : super(UserState.initial());

  final AuthUsecases _authUsecases;

  ContractorUser? getUserData() {
    final userData = _authUsecases.userData;

    emit(UserState(status: GeneralState.loaded, user: userData));

    return userData;
  }

  Future<void> acceptTermsAndConditions() async =>
      (await _authUsecases.acceptTermsAndCondtions()).fold(
        (failure) => emit(
          state.copyWith(
            result: Failure(
              type: FailureType.general,
              severity: FailureSeverity.warning,
              message: S.current.generic_error_message,
            ),
          ),
        ),
        (_) => getUserData(),
      );

  @override
  void clearResult() => emit(state.copyWith());
}
