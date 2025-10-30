part of '../ok_mobile_returns.dart';

class MasterDataState extends Equatable implements BaseState {
  const MasterDataState({
    required this.packages,
    required this.state,
    this.result,
  });

  factory MasterDataState.initial() =>
      const MasterDataState(packages: <Package>[], state: GeneralState.loaded);

  final List<Package> packages;
  final Result? result;
  final GeneralState state;

  @override
  List<Object?> get props => [packages, state, result];

  MasterDataState copyWith({
    List<Package>? packages,
    Result? result,
    GeneralState? state,
  }) {
    return MasterDataState(
      packages: packages ?? this.packages,
      result: result,
      state: state ?? this.state,
    );
  }

  @override
  GeneralState get generalState => state;

  @override
  Result? get resultObject => result;
}
