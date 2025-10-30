part of '../ok_mobile_translations.dart';

@injectable
class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit(this._localizationUsecases)
    : super(LocalizationState.initial()) {
    _setInitialLocale();
  }

  final LocalizationUsecases _localizationUsecases;

  Future<void> _setInitialLocale() async {
    final preferedLanguage = await _localizationUsecases.getPreferedLangauge();

    if (preferedLanguage != null) {
      emit(state.copyWith(currentLocale: Locale(preferedLanguage)));
    } else {
      final deviceLanguage = await _localizationUsecases.getDeviceLanguage();

      final validLocale = AppLocales.locales.firstWhere(
        (element) => element.languageCode == deviceLanguage,
        orElse: () => const Locale('pl'),
      );

      emit(state.copyWith(currentLocale: validLocale));
    }
  }

  Future<void> changeLocale(Locale locale) async {
    await _localizationUsecases.setPreferedLangauge(locale.languageCode);
    emit(state.copyWith(currentLocale: locale));
  }
}
