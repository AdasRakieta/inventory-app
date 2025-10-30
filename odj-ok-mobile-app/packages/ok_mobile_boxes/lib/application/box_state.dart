part of '../ok_mobile_boxes.dart';

class BoxState extends Equatable implements BaseState {
  const BoxState({
    required this.state,
    required this.result,
    required this.selectedBox,
    this.openBoxes = const [],
    this.closedBoxes = const [],
  });

  factory BoxState.initial() {
    return BoxState(
      state: GeneralState.loaded,
      selectedBox: Box.empty(),
      result: null,
    );
  }

  final GeneralState state;
  final Result? result;
  final List<Box> openBoxes;
  final List<Box> closedBoxes;
  final Box selectedBox;

  List<Box> get allBoxes => [...closedBoxes, ...openBoxes];

  BoxState copyWith({
    GeneralState? state,
    Result? result,
    List<Box>? openBoxes,
    List<Box>? closedBoxes,
    Box? selectedBox,
  }) {
    return BoxState(
      state: state ?? this.state,
      result: result,
      openBoxes: openBoxes ?? this.openBoxes,
      closedBoxes: closedBoxes ?? this.closedBoxes,
      selectedBox: selectedBox ?? this.selectedBox,
    );
  }

  @override
  GeneralState get generalState => state;

  @override
  Result? get resultObject => result;

  @override
  List<Object?> get props => [
    state,
    openBoxes,
    closedBoxes,
    result,
    selectedBox,
  ];
}
