part of '../../ok_mobile_counting_center.dart';

class ReceivalsState extends Equatable implements BaseState {
  const ReceivalsState({
    required this.state,
    required this.result,
    this.plannedReceivals,
    this.currentReceival,
    this.lastAddedBag,
    this.collectedReceivals,
    this.selectedReceival,
  });

  factory ReceivalsState.initial() {
    return const ReceivalsState(
      state: GeneralState.loaded,
      result: null,
      plannedReceivals: ReceivalsResponse(ccPickups: [], packages: []),
      collectedReceivals: ReceivalsResponse(ccPickups: [], packages: []),
    );
  }

  final GeneralState state;
  final Pickup? currentReceival;
  final Result? result;
  final Bag? lastAddedBag;
  final ReceivalsResponse? plannedReceivals;
  final ReceivalsResponse? collectedReceivals;
  final Pickup? selectedReceival;

  ReceivalsState copyWith({
    GeneralState? state,
    Result? Function()? result,
    Bag? lastAddedBag,
    Pickup? Function()? currentReceival,
    ReceivalsResponse? plannedReceivals,
    ReceivalsResponse? collectedReceivals,
    Pickup? selectedReceival,
  }) {
    return ReceivalsState(
      state: state ?? this.state,
      result: result != null ? result() : this.result,
      lastAddedBag: lastAddedBag ?? this.lastAddedBag,
      currentReceival:
          currentReceival != null ? currentReceival() : this.currentReceival,
      plannedReceivals: plannedReceivals ?? this.plannedReceivals,
      collectedReceivals: collectedReceivals ?? this.collectedReceivals,
      selectedReceival: selectedReceival ?? this.selectedReceival,
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
    lastAddedBag,
    currentReceival,
    plannedReceivals,
    collectedReceivals,
    selectedReceival,
  ];
}
