part of '../../ok_mobile_auth.dart';

class UserState extends Equatable implements BaseState {
  const UserState({required this.status, this.user, this.result});

  factory UserState.initial() => const UserState(status: GeneralState.loaded);

  final GeneralState status;
  final ContractorUser? user;
  final Result? result;

  UserState copyWith({
    GeneralState? status,
    ContractorUser? user,
    Result? result,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      result: result,
    );
  }

  @override
  List<Object?> get props => [status, user, result];

  @override
  GeneralState get generalState => status;

  @override
  Result? get resultObject => result;
}
