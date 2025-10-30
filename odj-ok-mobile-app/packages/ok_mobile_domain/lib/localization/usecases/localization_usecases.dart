part of '../../ok_mobile_domain.dart';

@lazySingleton
class LocalizationUsecases {
  LocalizationUsecases(this._localizationRepository);

  final ILocalizationRepository _localizationRepository;

  Future<String> getDeviceLanguage() async {
    return _localizationRepository.getDeviceLanguage();
  }

  Future<String?> getPreferedLangauge() async {
    return _localizationRepository.getPreferedLanguage();
  }

  Future<void> setPreferedLangauge(String languageCode) async {
    return _localizationRepository.setPreferedLanguage(languageCode);
  }
}
