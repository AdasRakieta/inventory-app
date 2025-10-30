part of '../ok_mobile_common.dart';

@Singleton()
class PermissionService {
  bool _externalStoragePermissionRequested = false;
  bool _externalStoragePermissionGranted = false;

  /// Request external storage permission during app bootstrap
  /// This ensures logging and file operations work throughout the app lifecycle
  Future<bool> requestExternalStoragePermission() async {
    // If permission was already granted, return early
    if (_externalStoragePermissionRequested &&
        _externalStoragePermissionGranted) {
      return _externalStoragePermissionGranted;
    }

    _externalStoragePermissionRequested = true;

    try {
      final permission = await Permission.manageExternalStorage.request();
      _externalStoragePermissionGranted = permission.isGranted;

      if (!permission.isGranted) {
        LoggerService().trackError(
          'External storage permission denied',
          stackTrace: StackTrace.current,
        );
      }

      return _externalStoragePermissionGranted;
    } on Exception catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);
      return false;
    }
  }

  bool get isExternalStoragePermissionGranted =>
      _externalStoragePermissionGranted;

  Future<bool> checkExternalStoragePermission() async {
    try {
      final status = await Permission.manageExternalStorage.status;
      _externalStoragePermissionGranted = status.isGranted;
      return status.isGranted;
    } on Exception catch (e, stackTrace) {
      LoggerService().trackError(e, stackTrace: stackTrace);
      return false;
    }
  }
}
