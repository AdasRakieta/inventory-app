part of '../ok_mobile_returns.dart';

@injectable
class ReturnsCubit extends Cubit<ReturnsState> implements ISnackBarCubit {
  ReturnsCubit(this._returnsUsecases) : super(ReturnsState.initial()) {
    checkForCache();
  }

  final ReturnsUsecases _returnsUsecases;

  Future<void> checkForCache() async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _returnsUsecases.getCachedData();

    emit(state.copyWith(state: GeneralState.loaded, openedReturn: result));
  }

  Future<void> _saveCache() async {
    await _returnsUsecases.changeCachedData(state.openedReturn);
  }

  Future<void> removeCache() async {
    await _returnsUsecases.removeCache();
  }

  Future<void> fetchReturns() async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _returnsUsecases.fetchReturns();

    result.fold(
      (failure) => emit(
        state.copyWith(result: failure, state: GeneralState.error, returns: []),
      ),
      (returns) =>
          emit(state.copyWith(returns: returns, state: GeneralState.loaded)),
    );
  }

  void changeStateFilter(String routeName, ReturnState selectedState) {
    final selectedStatesPerRoute = Map<String, List<ReturnState>>.from(
      state.selectedStatesPerScreen,
    );

    final currentStates = selectedStatesPerRoute[routeName] ?? [];

    final updatedStates = currentStates.contains(selectedState)
        ? currentStates.where((s) => s != selectedState).toList()
        : [...currentStates, selectedState];

    selectedStatesPerRoute[routeName] = updatedStates;

    emit(state.copyWith(selectedStatesPerScreen: selectedStatesPerRoute));
  }

  void clearStateFilters() {
    emit(state.copyWith(selectedStatesPerScreen: {}));
  }

  void lockScanner() {
    emit(state.copyWith(isScannerLocked: true));
  }

  void unlockScanner() {
    emit(state.copyWith(isScannerLocked: false));
  }

  Future<bool> printVoucher({
    required String voucherId,
    required String voucherCode,
    required double depositValue,
    required String returnCode,
    required List<Package> packages,
    required String macAddress,
    required CollectionPointData collectionPoint,
    required ContractorData contractorData,
    ActionReason? reprintReason,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _returnsUsecases.requestVoucherPrint(
      voucherId,
      reprintReason: reprintReason,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (_) async {
        final dateString = DateFormat(
          'dd.MM.yy HH:mm:ss',
        ).format(DateTime.now());

        final showFooter = !packages.any(
          (package) => package.type == BagType.glass,
        );
        final contractorAddress =
            '${contractorData.addressStreet} '
            '${contractorData.addressBuilding}, '
            '${contractorData.addressPostalCode} '
            '${contractorData.addressCity}';

        final currentEnvironment = getIt<AppConfigProvider>().environment;

        final localLogoPath = await LogoLocalDatasource.logoPath;

        final (
          voucherContent,
          voucherLength,
        ) = await VoucherContentGenerator.generateVoucherContent(
          packages,
          address:
              '${collectionPoint.addressStreet} '
              '${collectionPoint.addressBuilding}, '
              '${collectionPoint.addressPostalCode} '
              '${collectionPoint.addressCity}',
          nip: collectionPoint.nip!,
          nr: collectionPoint.code,
          printDate: dateString,
          voucherNumber: voucherCode,
          voucherDepositValue: depositValue,
          krs: contractorData.krs ?? '',
          court: contractorData.court ?? '',
          reprint: reprintReason != null,
          showFooter: showFooter,
          contractorName: contractorData.name,
          contractorAddress: contractorAddress,
          contractorNip: contractorData.nip ?? '',
          contractorBdo: contractorData.bdoNumber ?? '',
          expiryDays:
              contractorData.voucherValidityInDays ??
              AppConstants.voucherValidityDays,
          disclaimer: contractorData.voucherAdditionalText,
          logoPath: localLogoPath,
          environment: currentEnvironment,
        );

        final errorMessage = await OkMobileZebraPrinter().printDocument(
          macAddress,
          voucherContent,
          voucherLength,
        );

        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: errorMessage != null
                ? Failure(
                    type: FailureType.general,
                    severity: FailureSeverity.error,
                    message: errorMessage,
                  )
                : null,
          ),
        );
        return errorMessage == null;
      },
    );
  }

  Future<bool> checkPrinter(String? macAddress) async {
    emit(state.copyWith(state: GeneralState.loading));

    if (macAddress == null || macAddress.isEmpty) {
      emit(
        state.copyWith(
          state: GeneralState.loaded,
          result: Failure(
            type: FailureType.noPrinterConfigured,
            severity: FailureSeverity.error,
            message: S.current.no_printer_configured,
          ),
        ),
      );
      return false;
    }

    emit(state.copyWith(state: GeneralState.loaded));

    return true;
  }

  Future<bool> confirmVoucherPrint(
    Return selectedReturn, {
    bool isReprint = false,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _returnsUsecases.confirmVoucherPrinted(
      selectedReturn.voucher!.id,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));
        return false;
      },
      (_) {
        final currentReturn = state.returns.firstWhere(
          (element) => element.id == selectedReturn.id,
        );

        final updatedReturn = currentReturn.copyWith(
          state: ReturnState.printed,
        );

        state.returns.remove(currentReturn);
        state.returns.insert(0, updatedReturn);

        emit(
          state.copyWith(
            state: GeneralState.loaded,
            result: Success(
              message: isReprint
                  ? S.current.reprint_voucher_confirmation
                  : S.current.voucher_printed_for_client,
            ),
          ),
        );

        return true;
      },
    );
  }

  Future<bool> cancelVoucherPrint(
    Return currentReturn, {
    required ActionReason reason,
  }) async {
    emit(state.copyWith(state: GeneralState.loading));

    final result = await _returnsUsecases.cancelVoucherPrint(
      currentReturn.voucher!.id,
      reason: reason,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(result: failure, state: GeneralState.loaded));

        return false;
      },
      (_) {
        // firstWhereOrNull is used here because at this point state.returns,
        // as they are being just fetched from the backend might not contain
        // the currentReturn
        final selectedReturn = state.returns.firstWhereOrNull(
          (element) => element.id == currentReturn.id,
        );
        state.returns.remove(selectedReturn);

        final newReturn = currentReturn.copyWith(
          voucherCancellationReason: reason,
          state: ReturnState.canceled,
        );
        // this line is to show the new return on top of the list
        state.returns.insert(0, newReturn);

        emit(state.copyWith(state: GeneralState.loaded));
      },
    );

    return true;
  }

  void createNewReturn() {
    emit(
      state.copyWith(
        openedReturn: Return(
          id: DateTime.now().toString().substring(20),
          packages: <Package>[],
          state: ReturnState.ongoing,
        ),
      ),
    );

    _saveCache();
  }

  void increasePackageQuantity(String ean, String bagId) {
    final openedReturn = state.openedReturn
      ..increasePackageQuantity(ean, bagId);

    emit(state.copyWith(openedReturn: openedReturn));

    _saveCache();
  }

  void decreasePackageQuantity(String ean, String? bagId, {BagType? bagType}) {
    final openedReturn = state.openedReturn
      ..decreasePackageQuantity(ean, bagId, bagType);

    emit(state.copyWith(openedReturn: openedReturn));

    _saveCache();
  }

  bool addPackage(Package package, [Bag? bag]) {
    if (state.isScannerLocked) {
      return false;
    }
    switch ((package.type, bag)) {
      case (BagType.glass, _):
        final openedReturn = state.openedReturn..addPackage(package);
        emit(state.copyWith(openedReturn: openedReturn));
        _saveCache();
        return false;
      case (_, null):
        final openedReturn = state.openedReturn..addPackage(package);
        lockScanner();
        emit(
          state.copyWith(
            openedReturn: openedReturn.copyWith(
              mostRecentPackage: () => package.copy(),
            ),
            result: Failure(
              type: FailureType.general,
              severity: FailureSeverity.warning,
              message: S.current.scanned_package_must_be_assigned_to_bag,
            ),
          ),
        );
        _saveCache();
        return true;
      case (_, final Bag bag):
        if (bag.type == BagType.mix || bag.type == package.type) {
          final packageToAdd = package.copyWith(bagId: bag.id);
          final openedReturn = state.openedReturn..addPackage(packageToAdd);
          emit(state.copyWith(openedReturn: openedReturn));
          _saveCache();
          return false;
        } else {
          final openedReturn = state.openedReturn..addPackage(package);
          lockScanner();
          emit(
            state.copyWith(
              openedReturn: openedReturn.copyWith(
                mostRecentPackage: () => package.copy(),
              ),
              result: Failure(
                type: FailureType.general,
                severity: FailureSeverity.warning,
                message: S.current.scanned_package_requires_bag_change,
              ),
            ),
          );
          _saveCache();
          return true;
        }
      default:
        return false;
    }
  }

  void removePackage(String ean, String? bagId, {BagType? bagType}) {
    final openedReturn = state.openedReturn..removePackage(ean, bagId, bagType);

    emit(state.copyWith(openedReturn: openedReturn));

    _saveCache();
  }

  void rejectReturn() {
    emit(state.copyWith(openedReturn: Return.empty()));
    unlockScanner();
    removeCache();
  }

  Future<String?> closeReturn(VoucherDisplayType voucherDisplayType) async {
    emit(state.copyWith(state: GeneralState.loading));

    final openedReturn = state.openedReturn.copyWith(
      closedTime: DateTime.now(),
      state: ReturnState.unfinished,
    );
    String? newId;

    final result = await _returnsUsecases.closeReturn(openedReturn);

    result.fold(
      (failure) =>
          emit(state.copyWith(result: failure, state: GeneralState.loaded)),
      (data) {
        final confirmedReturn = state.openedReturn.copyWith(
          voucher: data.voucher,
          id: data.id,
          code: data.code,
        );
        final returns = List<Return>.from(state.returns)..add(confirmedReturn);
        newId = data.id;

        emit(
          state.copyWith(
            openedReturn: Return.empty(),
            returns: returns,
            result: Success(
              message: voucherDisplayType.getClosedReturnMessage(),
            ),
            state: GeneralState.loaded,
          ),
        );

        removeCache();
      },
    );
    return newId;
  }

  bool checkIfBagContainsOpenReturnPackages(Bag bag) {
    final openedReturn = state.openedReturn;

    if (openedReturn.packages.isEmpty) {
      return true;
    }

    for (final package in openedReturn.packages) {
      if (package.bagId == bag.id) {
        emit(
          state.copyWith(
            result: Failure(
              type: FailureType.general,
              severity: FailureSeverity.error,
              message: S.current.bag_contains_open_return_packages,
            ),
          ),
        );
        return false;
      }
    }

    return true;
  }

  void clearMostRecentPackage({String? customMessage}) {
    final mostRecentPackage = state.openedReturn.mostRecentPackage;
    if (mostRecentPackage == null) {
      return;
    }
    final packagesInReturn = state.openedReturn.packages..removeAt(0);
    unlockScanner();
    emit(
      state.copyWith(
        openedReturn: state.openedReturn.copyWith(
          packages: packagesInReturn,
          mostRecentPackage: () => null,
        ),
        result: Failure(
          type: FailureType.general,
          severity: FailureSeverity.warning,
          message: customMessage ?? S.current.last_package_removed_from_return,
        ),
      ),
    );
    _saveCache();
  }

  void assignMostRecentPackageToBag(Bag bag) {
    final mostRecentPackage = state.openedReturn.mostRecentPackage;
    if (mostRecentPackage == null) {
      return;
    }
    final packageType = mostRecentPackage.type;
    if (packageType == bag.type ||
        ((packageType == BagType.plastic || packageType == BagType.can) &&
            bag.type == BagType.mix)) {
      final updatedPackage = mostRecentPackage.copyWith(bagId: bag.id);
      unlockScanner();
      emit(
        state.copyWith(
          openedReturn: state.openedReturn.copyWith(
            packages: [updatedPackage, ...state.openedReturn.packages.skip(1)],
            mostRecentPackage: () => null,
          ),
        ),
      );
      _saveCache();
    }
  }

  @override
  void clearResult() {
    emit(state.copyWith());
  }
}
