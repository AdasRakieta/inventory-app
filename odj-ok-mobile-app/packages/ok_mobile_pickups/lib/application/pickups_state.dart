part of '../ok_mobile_pickups.dart';

class PickupsState extends Equatable implements BaseState {
  const PickupsState({
    required this.state,
    required this.result,
    this.selectedBags = const [],
    this.pickups = const [],
    this.selectedPickup,
  });

  factory PickupsState.initial() {
    return const PickupsState(state: GeneralState.loaded, result: null);
  }

  final GeneralState state;
  final Result? result;
  final List<Bag> selectedBags;
  final List<Pickup> pickups;
  final Pickup? selectedPickup;

  PickupsState copyWith({
    GeneralState? state,
    Result? result,
    List<Bag>? selectedBags,
    List<Pickup>? pickups,
    Pickup? selectedPickup,
  }) {
    return PickupsState(
      state: state ?? this.state,
      result: result,
      selectedBags: selectedBags ?? this.selectedBags,
      pickups: pickups ?? this.pickups,
      selectedPickup: selectedPickup ?? this.selectedPickup,
    );
  }

  @override
  GeneralState get generalState => state;

  @override
  Result? get resultObject => result;

  @override
  List<Object?> get props => [
    state,
    result,
    selectedBags,
    pickups,
    selectedPickup,
  ];
}
