part of '../ok_mobile_domain.dart';

enum FailureType {
  labelDuplicate,
  bagAlreadyAddedToBox,
  bagAlreadyClosed,
  bagNotClosed,
  bagNotFound,
  bagNotAssignedToCollectionPoint,
  boxAlreadyClosed,
  boxNotFound,
  boxNotAssignedToCollectionPoint,
  dataAlreadyUpToDate,
  general,
  noInternet,
  noPrinterConfigured,
  sealAlreadyExists,
  tokenRefreshFailed,
  unknownEanCode,
  userCancelledAuth,
  wrongPackageType,
  wrongDeviceAssignmentToCountingCenter,
  wrongUserAssignmentToCountingCenter,
  wrongDeviceAssignmentToRetailChain,
  wrongUserAssignmentToRetailChain,
  wrongDeviceAssignmentToCollectionPoint,
  wrongUserAssignmentToCollectionPoint,
  wrongUserConfiguration,
  noAccess,
}

enum FailureSeverity { error, warning }

class Failure extends Equatable implements Result {
  const Failure({required this.type, required this.severity, this.message});

  final FailureType type;
  final FailureSeverity severity;
  @override
  final String? message;

  @override
  List<Object?> get props => [type, severity, message];
}

class NoInternetFailure extends Failure {
  NoInternetFailure()
    : super(
        type: FailureType.noInternet,
        severity: FailureSeverity.error,
        message: S.current.no_internet,
      );
}
