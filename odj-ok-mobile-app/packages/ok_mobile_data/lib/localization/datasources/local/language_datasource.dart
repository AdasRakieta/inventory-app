part of '../../../ok_mobile_data.dart';

class LanguageDatasource {
  Future<String> getDeviceLanguage() async {
    return Platform.localeName.split('_')[0];
  }

  Future<String?> getPreferedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(CacheKeys.preferedLanguage);
  }

  Future<void> setPreferedLanguage(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(CacheKeys.preferedLanguage, languageCode);
  }
}
