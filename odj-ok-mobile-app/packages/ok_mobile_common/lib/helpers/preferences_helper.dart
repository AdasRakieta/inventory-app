part of '../ok_mobile_common.dart';

class PreferencesHelper {
  static const String _lastModifiedDateKey = 'lastModifiedDate';
  static const String _versionKey = 'masterDataVersion';

  Future<bool> getMasterDataCheckedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(_lastModifiedDateKey);

    final lastCheckedDate = DateTime.tryParse(result ?? '');

    if (lastCheckedDate != null) {
      return lastCheckedDate.isToday;
    }

    return false;
  }

  Future<bool> setMasterDataVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_versionKey, version);
  }

  Future<bool> getMasterDataVersionChanged(int version) async {
    final prefs = await SharedPreferences.getInstance();
    return version != prefs.getInt(_versionKey);
  }

  Future<void> setMasterDataCheckedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastModifiedDateKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> clearMasterDataPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_lastModifiedDateKey),
      prefs.remove(_versionKey),
    ]);
  }
}
