part of '../../ok_mobile_counting_center.dart';

@injectable
class ReceivalsCubit extends Cubit<ReceivalsState> implements ISnackBarCubit {
  ReceivalsCubit(this._receivalsUsecases) : super(ReceivalsState.initial());

  final ReceivalsUsecases _receivalsUsecases;

  void addBagToReceival(Bag bag) {
    emit(
      state.copyWith(
        currentReceival: () => state.currentReceival!.addBags([bag]),
        lastAddedBag: bag,
      ),
    );
  }

  Future<Bag?> validateBag(String sealNumber, String countingCenterId) async {
    if (state.currentReceival!.bags!.any((bag) => bag.seal == sealNumber)) {
      emit(
        state.copyWith(
          result:
              () => Failure(
                type: FailureType.general,
                severity: FailureSeverity.warning,
                message: S.current.bag_already_added_to_receival,
              ),
        ),
      );
      return null;
    }
    emit(state.copyWith(state: GeneralState.loading));
    final result = await _receivalsUsecases.validateBag(
      sealNumber,
      countingCenterId,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: () => failure, state: GeneralState.loaded));
        return null;
      },
      (bag) {
        emit(state.copyWith(state: GeneralState.loaded));
        return bag;
      },
    );
  }

  Future<bool> confirmReceival(String countingCenterId) async {
    emit(state.copyWith(state: GeneralState.loading));
    final result = await _receivalsUsecases.confirmReceival(
      state.currentReceival!.bags!,
      countingCenterId,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(result: () => failure, state: GeneralState.loaded));
        return false;
      },
      (statusCode) {
        Success success;

        if (statusCode == 202) {
          success = Success(message: S.current.packages_receival_confirmation);
        } else {
          success = Success(
            message: S.current.packages_receival_confirmation_duplicates,
          );
        }
        emit(
          state.copyWith(
            result: () => success,
            currentReceival: () => null,
            state: GeneralState.loaded,
          ),
        );
        return true;
      },
    );
  }

  Future<void> getPlannedReceivals(String countingCenterId) async {
    emit(state.copyWith(state: GeneralState.loading));
    final result = await _receivalsUsecases.getPlannedReceivals(
      countingCenterId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(result: () => failure, state: GeneralState.loaded));
      },
      (plannedReceivals) {
        plannedReceivals?.ccPickups.sort((a, b) {
          return -a.dateAdded.compareTo(b.dateAdded);
        });
        emit(
          state.copyWith(
            plannedReceivals: plannedReceivals,
            state: GeneralState.loaded,
          ),
        );
      },
    );
  }

  void startNewReceival() {
    if (state.currentReceival == null) {
      final newReceival = Pickup.empty();
      emit(state.copyWith(currentReceival: () => newReceival));
    }
  }

  Future<void> getCollectedReceivals(String countingCenterId) async {
    emit(state.copyWith(state: GeneralState.loading));
    final result = await _receivalsUsecases.getCollectedReceivals(
      countingCenterId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(result: () => failure, state: GeneralState.loaded));
      },
      (collectedReceivals) {
        collectedReceivals?.ccPickups.sort((a, b) {
          return -a.dateAdded.compareTo(b.dateAdded);
        });
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            collectedReceivals: collectedReceivals,
          ),
        );
      },
    );
  }

  Future<void> getReceivalData(String pickupId) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _receivalsUsecases.getReceivalData(pickupId: pickupId);

    result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.loaded, result: () => failure));
      },
      (receivalData) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            selectedReceival: receivalData,
          ),
        );
      },
    );
  }

  @override
  void clearResult() {
    emit(state.copyWith(result: () => null));
  }
}
