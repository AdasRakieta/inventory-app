part of '../../../ok_mobile_domain.dart';

class ExceptionHelper {
  static Failure handleDioException(
    DioException exception, {
    required StackTrace stackTrace,
    bool shouldLog = true,
    Failure Function()? on403,
    Failure Function()? on404,
    Failure Function()? on409,
  }) {
    final Failure failure;
    log(
      'Dio Exception: $exception, Response: ${exception.response}',
      stackTrace: stackTrace,
    );

    if (exception.error is SocketException) {
      failure = NoInternetFailure();
    } else if (exception.response != null) {
      final statusCode = exception.response!.statusCode;

      switch (statusCode) {
        case 304:
          failure = const Failure(
            type: FailureType.dataAlreadyUpToDate,
            severity: FailureSeverity.warning,
          );
        case 400:
          final responseData = decodeResponse(exception.response!);
          final failureEntity = FailureEntity.fromJson(responseData);
          final errorLabel = _extractFirstError(failureEntity.errors);
          failure = resolveFailureType(errorLabel);
        case 401:
          failure = Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.user_not_authorized,
          );
        case 403:
          failure =
              on403?.call() ??
              Failure(
                type: FailureType.general,
                severity: FailureSeverity.error,
                message: S.current.user_not_authorized,
              );
        case 404:
          failure =
              on404?.call() ??
              const Failure(
                type: FailureType.general,
                severity: FailureSeverity.error,
              );
        case 409:
          failure =
              on409?.call() ??
              const Failure(
                type: FailureType.general,
                severity: FailureSeverity.error,
              );
        case 510:
          failure = Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.token_not_provided,
          );
        case 500:
        default:
          failure = Failure(
            type: FailureType.general,
            severity: FailureSeverity.error,
            message: S.current.server_error,
          );
      }
    } else {
      failure = Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
        message: S.current.server_error,
      );
    }

    if (shouldLog) {
      LoggerService().trackError(
        exception,
        stackTrace: stackTrace,
        failure: failure,
      );
    }

    return failure;
  }

  static Failure handleGeneralException(
    Object exception, {
    required StackTrace stackTrace,
  }) {
    LoggerService().trackError(exception, stackTrace: stackTrace);
    log(exception.toString(), stackTrace: stackTrace);
    return Failure(
      type: FailureType.general,
      severity: FailureSeverity.error,
      message: S.current.server_error,
    );
  }

  static Failure resolveFailureType(String? errorLabel) {
    switch (errorLabel) {
      case 'LABEL_ALREADY_EXISTS':
        return Failure(
          type: FailureType.labelDuplicate,
          severity: FailureSeverity.warning,
          message: S.current.duplicated_label_error,
        );
      case 'BAG_ALREADY_CLOSED':
        return Failure(
          type: FailureType.bagAlreadyClosed,
          severity: FailureSeverity.warning,
          message: S.current.bag_already_closed,
        );
      case 'BAG_NOT_CLOSED':
        return Failure(
          type: FailureType.bagNotClosed,
          severity: FailureSeverity.warning,
          message: S.current.bag_not_closed,
        );
      case 'BAG_NOT_FOUND':
        return Failure(
          type: FailureType.bagNotFound,
          severity: FailureSeverity.warning,
          message: S.current.bag_not_found,
        );
      case 'BAG_NOT_ASSIGNED_TO_COLLECTION_POINT':
        return Failure(
          type: FailureType.bagNotAssignedToCollectionPoint,
          severity: FailureSeverity.warning,
          message: S.current.bag_not_assigned_to_collection_point,
        );
      case 'BAG_INCORRECT_COLLECTION_POINT':
        return Failure(
          type: FailureType.bagNotAssignedToCollectionPoint,
          severity: FailureSeverity.warning,
          message: S.current.bag_incorrect_collection_point,
        );
      case 'BAG_INCORRECT_ITEM_FOR_BAG':
        return Failure(
          type: FailureType.bagNotAssignedToCollectionPoint,
          severity: FailureSeverity.warning,
          message: S.current.bag_incorrect_item_for_bag,
        );
      case 'BOX_ALREADY_CLOSED':
        return Failure(
          type: FailureType.boxAlreadyClosed,
          severity: FailureSeverity.warning,
          message: S.current.bag_not_assigned_to_collection_point,
        );
      case 'BOX_NOT_FOUND':
        return Failure(
          type: FailureType.boxNotFound,
          severity: FailureSeverity.warning,
          message: S.current.box_not_found,
        );
      case 'BOX_NOT_ASSIGNED_TO_COLLECTION_POINT':
        return Failure(
          type: FailureType.boxNotAssignedToCollectionPoint,
          severity: FailureSeverity.error,
          message: S.current.bag_not_assigned_to_collection_point,
        );
      case 'BAG_IDS_EMPTY':
        return Failure(
          type: FailureType.boxNotAssignedToCollectionPoint,
          severity: FailureSeverity.error,
          message: S.current.no_bags_were_selected,
        );
      case 'BAG_ALREADY_ADDED_TO_BOX':
        return Failure(
          type: FailureType.bagAlreadyAddedToBox,
          severity: FailureSeverity.error,
          message: S.current.bag_already_added_to_box,
        );
      case 'SEAL_ALREADY_EXISTS':
        return Failure(
          type: FailureType.sealAlreadyExists,
          severity: FailureSeverity.warning,
          message: S.current.seal_already_exists,
        );
      case 'COLLECTION_POINT_EMPTY':
      case 'COLLECTION_POINT_ID_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.collection_point_id_empty,
        );
      case 'COLLECTION_POINT_NOT_EXISTS':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.collection_point_not_exist,
        );
      case 'SEAL_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.seal_empty,
        );
      case 'BAG_IS_OPEN':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.bag_is_open,
        );
      case 'REASON_INVALID':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.reason_invalid,
        );
      case 'LABEL_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.label_empty,
        );
      case 'TYPE_NOT_FOUND':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.type_not_found,
        );
      case 'TYPE_INVALID':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.type_invalid,
        );
      case 'BAG_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.bag_empty,
        );
      case 'BOX_IDS_EMPTY:':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.box_ids_empty,
        );
      case 'BOX_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.box_empty,
        );
      case 'EVENT_TYPE_INVALID:':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.event_type_invalid,
        );
      case 'COMMENT_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.comment_empty,
        );
      case 'ITEM_NOT_FOUND':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_not_found,
        );
      case 'ITEM_INCORRECT_COLLECTION_POINT':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_incorrect_collection_point,
        );
      case 'ITEM_NOT_CLOSED':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_not_closed,
        );
      case 'ITEM_ALREADY_HAS_PICKUP_STATUS':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_already_has_status,
        );
      case 'ITEM_ALREADY_HAS_PICKUP_ENTIRES':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_already_has_status,
        );
      case 'ITEMS_ARRAY_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.items_empty,
        );
      case 'COUNTING_CENTER_IS_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.cc_empty,
        );
      case 'ITEM_INCORRECT_COUNTING_CENTER':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_incorrect_cc,
        );
      case 'ITEM_NOT_RELEASED':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.item_not_released,
        );
      case 'BAG_RECEIVED':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.bag_already_received,
        );
      case 'BAG_NOT_RELEASED':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.bag_not_released,
        );
      case 'EAN_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.ean_empty,
        );
      case 'EAN_NOT_FOUND':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.ean_not_found,
        );
      case 'QUANTITY_LESS_OR_EQUAL_ZERO':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.quantity_less_or_equal_zero,
        );
      case 'DEVICE_ID_EMPTY':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.device_id_empty,
        );
      case 'DEVICE_ID_TOO_LONG':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.device_id_too_long,
        );
      case 'INVALID_DEVICE_ID':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.invalid_device_id,
        );
      case 'SEAL_INVALID_FORMAT':
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: S.current.invalid_seal_format,
        );
      default:
        return Failure(
          type: FailureType.general,
          severity: FailureSeverity.error,
          message: errorLabel,
        );
    }
  }

  static String handleZebraError(String errorMessage) {
    switch (errorMessage) {
      case final msg when msg.contains('is not a valid Bluetooth address'):
        return S.current.printer_bluetooth_address_not_valid_error_message;

      case final msg
          when msg.contains('Could not connect to device: read failed'):
        return S.current.printer_not_turned_on_error_message;

      case final msg
          when msg.contains(
            'Could not connect to device: Connection Exception',
          ):
        return S.current.printer_bluetooth_not_turned_on_error_message;

      default:
        return S.current.general_printer_error_message;
    }
  }

  static Map<String, dynamic> decodeResponse(Response<dynamic> response) {
    try {
      return jsonDecode(response.data.toString()) as Map<String, dynamic>;
    } on FormatException {
      return response.data as Map<String, dynamic>;
    }
  }

  static String? _extractFirstError(Map<String, dynamic>? errors) {
    return (errors?.entries.isNotEmpty ?? false) &&
            (errors!.entries.first.value as List).isNotEmpty
        ? (errors.entries.first.value as List).first as String?
        : null;
  }
}
