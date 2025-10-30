part of '../ok_mobile_admin.dart';

@singleton
class AdminCubit extends Cubit<AdminState> implements ISnackBarCubit {
  AdminCubit(this._adminUsecases) : super(AdminState.initial()) {
    _getPrinter();
  }

  final AdminUsecases _adminUsecases;

  Future<void> _getPrinter() async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _adminUsecases.getPrinter();

    result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.error, result: failure));
      },
      (macAddress) {
        emit(
          state.copyWith(
            selectedPrinterMacAddress: macAddress,
            state: GeneralState.loaded,
          ),
        );
      },
    );
  }

  Future<void> addPrinter(String macAddress) async {
    emit(state.copyWith(state: GeneralState.loading));

    final upperCaseMacAddress = macAddress.toUpperCase();

    final result = await _adminUsecases.addPrinter(upperCaseMacAddress);

    result.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.error, result: failure));
      },
      (_) {
        emit(
          state.copyWith(
            selectedPrinterMacAddress: upperCaseMacAddress,
            state: GeneralState.loaded,
            result: Success(
              message: S.current.printer_was_chosen(upperCaseMacAddress),
            ),
          ),
        );
      },
    );
  }

  Future<void> removePrinter() async {
    emit(
      state.copyWith(
        state: GeneralState.loading,
        selectedPrinterMacAddress: state.selectedPrinterMacAddress,
      ),
    );

    final result = await _adminUsecases.removePrinter();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            selectedPrinterMacAddress: state.selectedPrinterMacAddress,
            state: GeneralState.error,
            result: failure,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: Success(message: S.current.removed_last_printer),
          ),
        );
      },
    );
  }

  @override
  void clearResult() {
    emit(
      state.copyWith(
        selectedPrinterMacAddress: state.selectedPrinterMacAddress,
      ),
    );
  }
}
