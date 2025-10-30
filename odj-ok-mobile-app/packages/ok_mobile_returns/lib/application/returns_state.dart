part of '../ok_mobile_returns.dart';

class ReturnsState implements BaseState, EquatableMixin {
  const ReturnsState({
    required this.returns,
    required this.state,
    required this.openedReturn,
    required this.selectedStatesPerScreen,
    this.result,
    this.isScannerLocked = false,
  }) : super();

  factory ReturnsState.initial() => ReturnsState(
    state: GeneralState.loaded,
    returns: const <Return>[],
    openedReturn: Return.empty(),
    selectedStatesPerScreen: const <String, List<ReturnState>>{},
  );

  final List<Return> returns;
  final Result? result;
  final GeneralState state;
  final Return openedReturn;
  final Map<String, List<ReturnState>> selectedStatesPerScreen;
  final bool isScannerLocked;

  bool get isReturnInProgress => openedReturn.id.isNotEmpty;

  List<ReturnState> selectedStatesForScreen(String routeName) =>
      List<ReturnState>.from(
        selectedStatesPerScreen[routeName] ?? const <ReturnState>[],
      );

  List<Return> filteredReturnsPerScreen(String routeName) {
    final selected = selectedStatesForScreen(routeName);
    if (selected.isEmpty) {
      return returns
          .where((element) => element.state != ReturnState.unfinished)
          .toList();
    }
    return returns
        .where((element) => selected.contains(element.state))
        .toList();
  }

  List<Return> filteredReturnsByUnfinished(
    DateTime selectedDate,
    String routeName,
  ) {
    return returns
        .where((element) => element.state == ReturnState.unfinished)
        .toList();
  }

  List<Return> filteredReturnsPerScreenByDay(
    DateTime selectedDate,
    String routeName,
  ) => filteredReturnsPerScreen(routeName)
      .where(
        (element) => DatesHelper.isTheSameDay(element.closedTime, selectedDate),
      )
      .toList();

  ReturnsState copyWith({
    List<Return>? returns,
    Result? result,
    GeneralState? state,
    Return? openedReturn,
    Map<String, List<ReturnState>>? selectedStatesPerScreen,
    bool? isScannerLocked,
  }) {
    return ReturnsState(
      returns: returns ?? this.returns,
      result: result,
      state: state ?? this.state,
      openedReturn: openedReturn ?? this.openedReturn,
      selectedStatesPerScreen:
          selectedStatesPerScreen ?? this.selectedStatesPerScreen,
      isScannerLocked: isScannerLocked ?? this.isScannerLocked,
    );
  }

  @override
  List<Object?> get props => [
    returns,
    result,
    state,
    openedReturn,
    selectedStatesPerScreen,
    isScannerLocked,
  ];

  @override
  GeneralState get generalState => state;

  @override
  Result? get resultObject => result;

  @override
  bool? get stringify => true;
}
