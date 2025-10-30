part of '../ok_mobile_returns.dart';

@injectable
class MasterDataCubit extends Cubit<MasterDataState> implements ISnackBarCubit {
  MasterDataCubit(this._masterDataUsecases) : super(MasterDataState.initial());

  final MasterDataUsecases _masterDataUsecases;

  Future<void> fetchMasterData({bool useMasterdataV2 = false}) async {
    emit(state.copyWith(state: GeneralState.loading));

    final updateResult = await _masterDataUsecases.updateMasterData();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(state: GeneralState.loaded, result: failure));
      },
      (_) {
        emit(
          state.copyWith(
            state: GeneralState.loaded,
            packages: _masterDataUsecases.packages,
          ),
        );
      },
    );
  }

  Package? getPackageByEan(String code, {bool showErrorMessage = true}) {
    final result = _masterDataUsecases.getPackageByEan(code);

    if (result == null && showErrorMessage) {
      emit(
        state.copyWith(
          result: Failure(
            type: FailureType.unknownEanCode,
            severity: FailureSeverity.warning,
            message: S.current.unknown_ean_code,
          ),
        ),
      );
    }

    return result;
  }

  String? getPackageDescription(String ean) =>
      _masterDataUsecases.getPackageDescription(ean);

  BagType? getPackageType(String ean) =>
      _masterDataUsecases.getPackageType(ean);

  @override
  void clearResult() {
    emit(state.copyWith());
  }
}
