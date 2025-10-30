part of '../ok_mobile_bags.dart';

class BagsState implements BaseState, EquatableMixin {
  const BagsState({
    required this.state,
    this.selectedBag,
    this.currentReturnSelectedBag,
    this.result,
    this.selectedBagTypes = BagType.values,
    this.selectedBagStates = BagState.values,
    this.bagsToShow = const <Bag>[],
    this.openBags = const <Bag>[],
    this.closedBags = const <Bag>[],
    this.selectedBags = const <Bag>[],
    this.bagsToAddToBox = const <Bag>[],
  });

  factory BagsState.initial() => const BagsState(state: GeneralState.loaded);

  final Result? result;
  final Bag? selectedBag;
  final Bag? currentReturnSelectedBag;
  final GeneralState state;
  final List<BagType> selectedBagTypes;
  final List<BagState> selectedBagStates;
  final List<Bag> bagsToShow;
  final List<Bag> openBags;
  final List<Bag> closedBags;
  final List<Bag> selectedBags;
  final List<Bag> bagsToAddToBox;

  BagsState copyWith({
    Result? result,
    GeneralState? state,
    List<BagType>? selectedBagTypes,
    List<BagState>? selectedBagStates,
    List<Bag>? bagsToShow,
    Bag? Function()? selectedBag,
    Bag? Function()? currentReturnSelectedBag,
    List<Bag>? openBags,
    List<Bag>? closedBags,
    List<Bag>? selectedBags,
    List<Bag>? bagsToAddToBox,
  }) {
    return BagsState(
      result: result,
      state: state ?? this.state,
      selectedBagTypes: selectedBagTypes ?? this.selectedBagTypes,
      selectedBagStates: selectedBagStates ?? this.selectedBagStates,
      bagsToShow: bagsToShow ?? this.bagsToShow,
      selectedBag: selectedBag != null ? selectedBag.call() : this.selectedBag,
      currentReturnSelectedBag: currentReturnSelectedBag != null
          ? currentReturnSelectedBag.call()
          : this.currentReturnSelectedBag,
      openBags: openBags ?? this.openBags,
      closedBags: closedBags ?? this.closedBags,
      selectedBags: selectedBags ?? this.selectedBags,
      bagsToAddToBox: bagsToAddToBox ?? this.bagsToAddToBox,
    );
  }

  List<Bag> get allBags => [...openBags, ...closedBags];

  List<Bag> get bagsSorted =>
      (bagsToShow..sortBy<DateTime>((bag) => bag.openedTime ?? DateTime.now()))
          .reversed
          .toList();

  @override
  List<Object?> get props => [
    result,
    state,
    selectedBagTypes,
    selectedBagStates,
    bagsToShow,
    selectedBag,
    currentReturnSelectedBag,
    openBags,
    closedBags,
    selectedBags,
    bagsToAddToBox,
  ];

  @override
  GeneralState get generalState => state;

  @override
  Result? get resultObject => result;

  @override
  bool? get stringify => true;
}
