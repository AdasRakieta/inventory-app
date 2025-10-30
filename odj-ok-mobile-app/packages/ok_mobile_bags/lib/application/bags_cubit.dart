part of '../ok_mobile_bags.dart';

@singleton
class BagsCubit extends Cubit<BagsState> implements ISnackBarCubit {
  BagsCubit(this._bagsUsecases) : super(BagsState.initial());

  final BagsUsecases _bagsUsecases;

  Future<void> fetchAllBags() async {
    await fetchClosedBags();
    await fetchOpenBags();
  }

  Future<void> fetchOpenBags() async {
    emit(state.copyWith(state: GeneralState.loading, bagsToShow: []));

    final result = await _bagsUsecases.fetchOpenBags();

    result.fold(
      (failure) =>
          emit(state.copyWith(result: failure, state: GeneralState.loaded)),
      (bags) =>
          emit(state.copyWith(openBags: bags, state: GeneralState.loaded)),
    );
  }

  Future<void> fetchClosedBags() async {
    emit(state.copyWith(state: GeneralState.loading, bagsToShow: []));

    final result = await _bagsUsecases.fetchClosedBags();

    result.fold(
      (failure) =>
          emit(state.copyWith(result: failure, state: GeneralState.loaded)),
      (bags) =>
          emit(state.copyWith(closedBags: bags, state: GeneralState.loaded)),
    );
  }

  Future<bool> openNewBag({
    required BagType bagType,
    required String bagLabel,
    required String collectionPointId,
  }) async {
    var status = false;

    emit(state.copyWith(state: GeneralState.loading));
    final bagMetadata = BagMetadata(
      type: bagType.backendName,
      label: bagLabel,
      collectionPointId: collectionPointId,
    );

    final result = await _bagsUsecases.addBag(bagMetadata);

    result.fold(
      (failure) {
        log(failure.message!);
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
      },
      (bagWithId) {
        emit(
          state.copyWith(
            currentReturnSelectedBag: () => bagWithId,
            openBags: [...state.openBags, bagWithId],
            result: Success(
              message: S.current.new_bag_properly_opened(bagLabel),
            ),
            state: GeneralState.loaded,
          ),
        );

        status = true;
      },
    );

    return status;
  }

  void selectBag({
    required Bag bag,
    bool showSnackBar = false,
    String? customMessage,
  }) {
    emit(
      state.copyWith(
        selectedBag: () => bag,
        result: showSnackBar
            ? Success(
                message:
                    customMessage ??
                    S.current.bag_was_chosen_with_type(
                      bag.label,
                      bag.type.localisedName,
                    ),
              )
            : null,
      ),
    );
  }

  void clearSelectedBag() {
    emit(state.copyWith(selectedBag: () => null));
  }

  void clearCurrentReturnSelectedBag() {
    emit(state.copyWith(currentReturnSelectedBag: () => null));
  }

  Bag? selectBagById(String bagId) {
    final bag = _bagsUsecases.getBagById(bagId);
    if (bag != null) {
      emit(state.copyWith(selectedBag: () => bag));
      return bag;
    } else {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      );
      return null;
    }
  }

  Bag? setCurrentReturnSelectedBagByLabel(String bagLabel) {
    final bag = _bagsUsecases.getBagByLabel(bagLabel);
    if (bag == null) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      );
      return null;
    } else if (bag.state == BagState.closed) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.bag_closed_choose_open_instead,
          ),
        ),
      );
      return null;
    } else {
      emit(
        state.copyWith(
          currentReturnSelectedBag: () => bag,
          result: Success(message: S.current.bag_was_chosen(bag.label)),
        ),
      );
      return bag;
    }
  }

  Bag? getBagByLabel(
    String bagLabel, {
    required String successMessage,
    bool onlyOpenBags = false,
    Return? currentlyOpenedReturn,
  }) {
    final bag = _bagsUsecases.getBagByLabel(bagLabel);

    if (bag == null) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      );
      return null;
    }
    final aggregatedPackagesNumber = ReturnsHelper.getNumberOfAllPackages(
      currentlyOpenedReturn,
      bag,
    );

    if (onlyOpenBags && bag.state == BagState.closed) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.bag_already_closed,
          ),
        ),
      );
      return null;
    } else if (onlyOpenBags && aggregatedPackagesNumber == 0) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.empty_bag_cannot_be_closed,
          ),
        ),
      );
      return null;
    } else {
      emit(
        state.copyWith(
          selectedBag: () => bag,
          result: Success(message: successMessage),
        ),
      );
      return bag;
    }
  }

  Bag? getBagBySeal(
    String bagSeal, {
    String? customMessage,
    String? customErrorMessage,
    bool showSnackBar = false,
  }) {
    final bag = _bagsUsecases.getBagBySeal(bagSeal);
    if (bag != null) {
      emit(
        state.copyWith(
          selectedBag: () => bag,
          result: showSnackBar ? Success(message: customMessage) : null,
        ),
      );
      return bag;
    } else {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: customErrorMessage ?? S.current.incorrect_seal_number,
          ),
        ),
      );
      return null;
    }
  }

  void getBagsAndSaveToState({
    List<BagType>? selectedTypes,
    List<BagState>? selectedStates,
  }) {
    final types = selectedTypes ?? state.selectedBagTypes;
    final states = selectedStates ?? state.selectedBagStates;

    final result = _bagsUsecases.getBags(
      selectedTypes: types,
      selectedStates: states,
    );

    emit(
      state.copyWith(
        result: state.result,
        bagsToShow: result,
        selectedBagTypes: selectedTypes,
        selectedBagStates: selectedStates,
      ),
    );
  }

  void changeTypeFilter({
    required BagType type,
    List<BagState> bagStates = const <BagState>[],
  }) {
    final types = List<BagType>.from(state.selectedBagTypes);

    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }

    getBagsAndSaveToState(selectedTypes: types, selectedStates: bagStates);
  }

  Future<bool> updateBagLabel(
    String bagId, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _bagsUsecases.updateBagLabel(
      bagId,
      newLabel: newLabel,
      reason: reason,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (success) {
        emit(
          state.copyWith(
            selectedBag: () => _bagsUsecases.getBagById(bagId),
            currentReturnSelectedBag: () => _bagsUsecases.getBagById(
              state.currentReturnSelectedBag?.id ?? '',
            ),
            state: GeneralState.loaded,
            result: success,
            openBags: _bagsUsecases.openBags,
            closedBags: _bagsUsecases.closedBags,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updateBagSeal(
    String bagId, {
    required String newSeal,
    required ActionReason reason,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _bagsUsecases.updateBagSeal(
      bagId,
      newSeal: newSeal,
      reason: reason,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (success) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: success,
            selectedBag: () => _bagsUsecases.getBagById(bagId),
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updateBag(
    String bagId, {
    required String newLabel,
    required String newSeal,
    required ActionReason reason,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _bagsUsecases.updateBag(
      bagId,
      newLabel: newLabel,
      newSeal: newSeal,
      reason: reason,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (success) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: success,
            // Only closed bags may have their seal changed
            closedBags: _bagsUsecases.closedBags,
          ),
        );
        return true;
      },
    );
  }

  List<Bag> getClosedBagsByIds(List<String> bagIds) {
    return state.closedBags.where((bag) => bagIds.contains(bag.id)).toList();
  }

  Future<bool> closeAndSealBag(String bagId, {required String seal}) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _bagsUsecases.closeAndSealBag(bagId, seal: seal);

    return result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.loaded, result: failure));
        return false;
      },
      (success) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: success,
            openBags: _bagsUsecases.openBags,
            closedBags: _bagsUsecases.closedBags,
            selectedBag: () => _bagsUsecases.getBagById(bagId),
            currentReturnSelectedBag: () => null,
          ),
        );
        return true;
      },
    );
  }

  Bag? checkIfClosedBagExists(String bagLabel) {
    final bag = state.closedBags.firstWhereOrNull(
      (bag) => bag.label == bagLabel,
    );

    if (bag == null) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_bag_number,
          ),
        ),
      );
    } else {
      if (checkIfAssignedToBox(bag)) {
        return null;
      }
    }
    return bag;
  }

  bool checkIfAssignedToBox(Bag bag) {
    if (bag.boxId != null) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.bagAlreadyAddedToBox,
            severity: FailureSeverity.warning,
            message: S.current.bag_already_added_to_box,
          ),
        ),
      );
    }
    return bag.boxId != null;
  }

  void selectBags(List<Bag> bags) {
    emit(state.copyWith(selectedBags: bags, bagsToShow: bags));
  }

  void unselectBag(Bag bag) {
    final updatedBags = List<Bag>.from(state.selectedBags)
      ..removeWhere((element) => element == bag);
    final updatedBagsToShow = List<Bag>.from(state.bagsToShow)
      ..removeWhere((element) => element == bag);
    final updatedBagsToAddToBox = List<Bag>.from(state.bagsToAddToBox)
      ..removeWhere((element) => element == bag);
    emit(
      state.copyWith(
        selectedBags: updatedBags,
        bagsToShow: updatedBagsToShow,
        bagsToAddToBox: updatedBagsToAddToBox,
      ),
    );
  }

  void filterSelectedBags(BagType bagType, {required bool value}) {
    if (value && !state.bagsToShow.any((element) => element.type == bagType)) {
      final updatedBags = <Bag>[
        ...state.bagsToShow,
        ...List.from(
          state.selectedBags.where((element) => element.type == bagType),
        ),
      ];
      emit(state.copyWith(bagsToShow: updatedBags));
    }
    if (!value) {
      final updatedBags = List<Bag>.from(state.bagsToShow)
        ..removeWhere((element) => element.type == bagType);
      emit(state.copyWith(bagsToShow: updatedBags));
    }
  }

  void issueWarning(String message) {
    emit(
      state.copyWith(
        result: Failure(
          type: FailureType.general,
          severity: FailureSeverity.warning,
          message: message,
        ),
      ),
    );
  }

  void showConfirmation(String message) {
    emit(state.copyWith(result: Success(message: message)));
  }

  Bag? checkIfClosedBagExistsBySeal(
    String seal, {
    bool considerBoxAssignment = true,
  }) {
    final bag = state.closedBags.firstWhereOrNull((bag) => bag.seal == seal);

    if (bag == null) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.incorrect_seal_number,
          ),
        ),
      );
    } else {
      if (considerBoxAssignment && checkIfAssignedToBox(bag)) {
        return null;
      }
    }
    return bag;
  }

  void addBagToBoxList(List<Bag> bags) {
    final updatedBags = List<Bag>.from(state.bagsToAddToBox)..addAll(bags);

    final updatedBagsSet = Set.of(updatedBags);

    emit(state.copyWith(bagsToAddToBox: updatedBagsSet.toList()));
  }

  void removeBagFromBoxList(Bag bag) {
    final updatedBags = List<Bag>.from(state.bagsToAddToBox)
      ..removeWhere((element) => element == bag);
    emit(state.copyWith(bagsToAddToBox: updatedBags));
  }

  void clearBagsToAddToBox() {
    emit(state.copyWith(bagsToAddToBox: []));
  }

  void clearSelectedBags() {
    emit(state.copyWith(selectedBags: []));
  }

  @override
  void clearResult() {
    emit(state.copyWith());
  }
}
