part of '../ok_mobile_common.dart';

class LogoLocalDatasource {
  static Future<String> get logoPath =>
      _getDirectory().then((path) => path + AppConstants.logoPath);

  static Future<String?> saveLogo(Uint8List logoBytes) async {
    try {
      if (!isTestExecution) {
        if (!getIt<PermissionService>().isExternalStoragePermissionGranted) {
          return null;
        }
      }

      final file = File(await logoPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(logoBytes);

      return file.path;
    } on Exception catch (e) {
      LoggerService().trackError(e, stackTrace: StackTrace.current);
      return null;
    }
  }

  static Future<void> saveLogoLastModifiedDate({
    required String lastModifiedDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(CacheKeys.contractorLogoLastModified, lastModifiedDate),
      ]);
    } on Exception catch (e) {
      LoggerService().trackError(e, stackTrace: StackTrace.current);
    }
  }

  static Future<String?> getCachedLogoLastModifiedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(CacheKeys.contractorLogoLastModified);
    } on Exception catch (e) {
      LoggerService().trackError(e, stackTrace: StackTrace.current);
      return null;
    }
  }

  static Future<void> clearLogo() async {
    try {
      await _deleteLogo(await logoPath);
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([prefs.remove(CacheKeys.contractorLogoLastModified)]);
    } on Exception catch (e) {
      LoggerService().trackError(e, stackTrace: StackTrace.current);
    }
  }

  static Future<void> _deleteLogo(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
    } on Exception catch (e) {
      LoggerService().trackError(e, stackTrace: StackTrace.current);
    }
  }

  static Future<String> _getDirectory() async {
    if (isTestExecution) {
      return Directory.current.path;
    } else {
      return ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS,
      );
    }
  }
}
