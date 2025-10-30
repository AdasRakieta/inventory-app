part of '../ok_mobile_pickups.dart';

@injectable
class PickupsCubit extends Cubit<PickupsState> implements ISnackBarCubit {
  PickupsCubit(this._pickupsUsecases, this._deviceConfigUsecases)
    : super(PickupsState.initial());

  final PickupsUsecases _pickupsUsecases;
  final DeviceConfigUsecases _deviceConfigUsecases;

  bool addBagToPickup(Bag bag) {
    final selectedBags = List<Bag>.from(state.selectedBags);
    if (selectedBags.contains(bag)) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.bag_already_added_to_pickup,
          ),
        ),
      );
      return false;
    } else {
      selectedBags.insert(0, bag);
      emit(state.copyWith(selectedBags: selectedBags));
      return true;
    }
  }

  void updateBagsInActivePickup() {
    final updatedBags = getIt<BagsUsecases>()
        .getBags(selectedStates: [BagState.closed])
        .where(
          (bag) =>
              state.selectedBags.any((bagInPickup) => bag.id == bagInPickup.id),
        )
        .toList();
    if (updatedBags.isNotEmpty) {
      emit(state.copyWith(selectedBags: updatedBags));
    }
  }

  void removeBagFromPickup(Bag bag) {
    final selectedBags = List<Bag>.from(state.selectedBags)..remove(bag);
    emit(state.copyWith(selectedBags: selectedBags));
  }

  Future<String?> confirmPickupAndPrintDocument(String macAddress) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _pickupsUsecases.confirmPickup(
      selectedBags: state.selectedBags,
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.loaded, result: failure));
        return null;
      },
      (pickupId) async {
        final pickup = await getPickupData(pickupId);
        var printSuccess = true;
        if (pickup != null) {
          printSuccess = await printPickupConfirmation(
            pickup: pickup,
            macAddress: macAddress,
          );
        }
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: printSuccess
                ? Success(message: S.current.pickup_confirmed)
                : Failure(
                    type: FailureType.general,
                    severity: FailureSeverity.warning,
                    message: S.current.pickup_confirmed_with_print_error,
                  ),
            selectedBags: [],
          ),
        );
        return pickupId;
      },
    );
  }

  Future<void> fetchPickups() async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _pickupsUsecases.fetchPickups(
      _deviceConfigUsecases.collectionPointData.id,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.loaded, result: failure));
      },
      (pickups) {
        final newPickups = List<Pickup>.from(pickups)
          ..sort((a, b) => -a.dateAdded.compareTo(b.dateAdded));
        emit(state.copyWith(state: GeneralState.loaded, pickups: newPickups));
      },
    );
  }

  Future<Pickup?> getPickupData(String pickupId) async {
    emit(
      state.copyWith(
        state: GeneralState.loading,
        selectedPickup: Pickup.empty(),
      ),
    );

    final result = await _pickupsUsecases.getPickupData(pickupId: pickupId);

    return result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.loaded, result: failure));
        return null;
      },
      (pickupData) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            selectedPickup: pickupData,
          ),
        );
        return pickupData;
      },
    );
  }

  Future<bool> printPickupConfirmation({
    required Pickup pickup,
    required String macAddress,
    bool showSnackBar = false,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final dateString = DateFormat('dd.MM.yy HH:mm:ss').format(pickup.dateAdded);

    final contractorData = _deviceConfigUsecases.collectionPointContractorData;

    final contractorAddress =
        '${contractorData.addressStreet} '
        '${contractorData.addressBuilding}, '
        '${contractorData.addressPostalCode} '
        '${contractorData.addressCity}';

    final collectionPointData = _deviceConfigUsecases.collectionPointData;

    final collectionPointAddress =
        '${collectionPointData.addressStreet} '
        '${collectionPointData.addressBuilding}, '
        '${collectionPointData.addressPostalCode} '
        '${collectionPointData.addressCity}';

    final bagsCount = pickup.bags?.length ?? 0;

    final countingCenter = collectionPointData.countingCenter;

    final countingCenterAddress =
        '${countingCenter?.addressStreet} ${countingCenter?.addressBuilding}, '
        '${countingCenter?.addressPostalCode} '
        '${countingCenter?.addressCity}';

    final (
      pickupConfirmationContent,
      pickupConfirmationLength,
    ) = await PickupConfirmationGenerator.generatePickupConfirmationContent(
      pickupCode: pickup.code ?? '',
      pickupDate: dateString,
      contractorName: contractorData.name,
      contractorAddress: contractorAddress,
      contractorNip: contractorData.nip ?? '',
      collectionPointName: collectionPointData.name ?? '',
      collectionPointNumber: collectionPointData.code,
      collectionPointAddress: collectionPointAddress,
      collectionPointNip: collectionPointData.nip ?? '',
      bagsCount: bagsCount,
      countingCenterName: countingCenter?.name ?? '',
      countingCenterAddress: countingCenterAddress,
      countingCenterNip: countingCenter?.nip ?? '',
    );

    final errorMessage = await OkMobileZebraPrinter().printDocument(
      macAddress,
      pickupConfirmationContent,
      pickupConfirmationLength,
    );

    emit(
      state.copyWith(
        state: GeneralState.loaded,
        result: errorMessage == null && showSnackBar
            ? Success(message: S.current.pickup_confirmation_printed_again)
            : errorMessage != null
            ? Failure(
                type: FailureType.general,
                severity: FailureSeverity.error,
                message: errorMessage,
              )
            : null,
      ),
    );

    return errorMessage == null;
  }

  @override
  void clearResult() {
    emit(state.copyWith());
  }
}
