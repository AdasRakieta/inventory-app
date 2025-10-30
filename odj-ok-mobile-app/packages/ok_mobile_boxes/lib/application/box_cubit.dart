part of '../ok_mobile_boxes.dart';

@singleton
class BoxCubit extends Cubit<BoxState> implements ISnackBarCubit {
  BoxCubit(this._boxUsecases) : super(BoxState.initial());

  final BoxUsecases _boxUsecases;

  void selectBox(Box box, {bool showSnackBar = true}) {
    emit(
      state.copyWith(
        selectedBox: box,
        result: showSnackBar
            ? Success(message: S.current.box_correctly_opened)
            : null,
      ),
    );
  }

  bool selectBoxByLabel(String label) {
    final box = state.allBoxes.firstWhereOrNull((box) => box.label == label);
    if (box != null) {
      emit(
        state.copyWith(
          selectedBox: box,
          result: Success(message: S.current.box_correctly_opened),
        ),
      );
      return true;
    } else {
      emit(
        state.copyWith(
          result: Failure(
            message: S.current.box_not_found,
            severity: FailureSeverity.warning,
            type: FailureType.general,
          ),
        ),
      );
      return false;
    }
  }

  Box? checkIfOpenBoxExists(String label) {
    final box = state.openBoxes.firstWhereOrNull((box) => box.label == label);
    if (box != null && box.bags.isNotEmpty) {
      return box;
    } else {
      emit(
        state.copyWith(
          result: Failure(
            message: S.current.box_not_found,
            severity: FailureSeverity.warning,
            type: FailureType.boxNotFound,
          ),
        ),
      );
      return null;
    }
  }

  Future<bool> openNewBox(String ean) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _boxUsecases.openNewBox(boxCode: ean);

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (box) {
        emit(
          state.copyWith(
            selectedBox: box,
            result: Success(message: S.current.new_box_opened_correctly),
            state: GeneralState.loaded,
          ),
        );
        return true;
      },
    );
  }

  Future<void> fetchOpenBoxes() async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _boxUsecases.fetchOpenBoxes();

    result.fold(
      (failure) =>
          emit(state.copyWith(result: failure, state: GeneralState.loaded)),
      (boxes) =>
          emit(state.copyWith(openBoxes: boxes, state: GeneralState.loaded)),
    );
  }

  Future<void> fetchClosedBoxes() async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _boxUsecases.fetchClosedBoxes();

    result.fold(
      (failure) =>
          emit(state.copyWith(result: failure, state: GeneralState.loaded)),
      (boxes) =>
          emit(state.copyWith(closedBoxes: boxes, state: GeneralState.loaded)),
    );
  }

  List<String> getSelectedBoxBagIds() {
    return state.selectedBox.bags.map((bag) => bag.id!).toList();
  }

  void updateBagsInfo(List<Bag> updatedBags) {
    emit(
      state.copyWith(
        selectedBox: state.selectedBox.copyWith(bags: updatedBags),
      ),
    );
  }

  Future<bool> addBagsToBox({required List<Bag> bags}) async {
    emit(state.copyWith(state: GeneralState.loading));

    final bagCodes = bags.map((bag) => bag.id!).toList();

    final result = await _boxUsecases.addBagsToBox(
      boxId: state.selectedBox.id,
      bagCodes: bagCodes,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (success) {
        final updatedBags = [...state.selectedBox.bags, ...bags];
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: success,
            selectedBox: state.selectedBox.copyWith(bags: updatedBags),
          ),
        );
        return true;
      },
    );
  }

  Future<void> removeBagFromBox(Bag bag) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _boxUsecases.removeBagFromBox(
      boxId: state.selectedBox.id,
      bagId: bag.id!,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
      },
      (success) {
        final updatedBags = List<Bag>.from(state.selectedBox.bags)..remove(bag);
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: success,
            selectedBox: state.selectedBox.copyWith(bags: updatedBags),
          ),
        );
      },
    );
  }

  Future<bool> closeBoxes(List<String> boxIds) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _boxUsecases.closeBoxes(boxIds);

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (success) {
        final closedBoxes =
            state.openBoxes.where((box) => boxIds.contains(box.id)).toList()
              ..forEach((box) => box.close());
        final updatedOpenBoxes = List<Box>.from(state.openBoxes)
          ..removeWhere((box) => boxIds.contains(box.id));
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: success,
            openBoxes: updatedOpenBoxes,
            closedBoxes: [...state.closedBoxes, ...closedBoxes],
          ),
        );
        return true;
      },
    );
  }

  void clearSelectedBox() {
    emit(state.copyWith(selectedBox: Box.empty()));
  }

  @override
  void clearResult() {
    emit(state.copyWith());
  }

  Future<bool> updateBoxLabel(
    String id, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));
    final result = await _boxUsecases.updateBoxLabel(
      id,
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
            result: success,
            selectedBox: state.selectedBox.copyWith(label: newLabel),
            state: GeneralState.loaded,
          ),
        );
        return true;
      },
    );
  }
}
