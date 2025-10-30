part of '../ok_mobile_translations.dart';

class LocalizationState extends Equatable {
  const LocalizationState({required this.currentLocale});

  factory LocalizationState.initial() =>
      const LocalizationState(currentLocale: Locale('en'));

  final Locale currentLocale;

  LocalizationState copyWith({Locale? currentLocale}) {
    return LocalizationState(
      currentLocale: currentLocale ?? this.currentLocale,
    );
  }

  @override
  List<Object?> get props => [currentLocale];
}
