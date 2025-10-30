part of '../../ok_mobile_domain.dart';

abstract class ILocalizationRepository {
  Future<String> getDeviceLanguage();
  Future<String?> getPreferedLanguage();
  Future<void> setPreferedLanguage(String languageCode);
}
