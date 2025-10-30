part of '../../ok_mobile_data.dart';

@Injectable(
  as: ILocalizationRepository,
  env: [
    AppEnvironment.dev,
    AppEnvironment.prd,
    AppEnvironment.tst,
    AppEnvironment.uat,
  ],
)
class LocalizationRepository extends ILocalizationRepository {
  LocalizationRepository();

  final LanguageDatasource _languageDatasource = LanguageDatasource();

  @override
  Future<String> getDeviceLanguage() async {
    return _languageDatasource.getDeviceLanguage();
  }

  @override
  Future<String?> getPreferedLanguage() async {
    return _languageDatasource.getPreferedLanguage();
  }

  @override
  Future<void> setPreferedLanguage(String languageCode) async {
    await _languageDatasource.setPreferedLanguage(languageCode);
  }
}
