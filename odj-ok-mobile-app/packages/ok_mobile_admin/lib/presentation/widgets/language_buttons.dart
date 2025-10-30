part of '../../ok_mobile_admin.dart';

class LanguageButtons extends StatefulWidget {
  const LanguageButtons({required this.locales, super.key});

  final List<Locale> locales;

  @override
  State<LanguageButtons> createState() => _LanguageButtonsState();
}

class _LanguageButtonsState extends State<LanguageButtons> {
  (Widget, String) localeData(Locale locale) {
    switch (locale.languageCode) {
      case 'uk':
        return (
          Assets.icons.ua.image(package: 'ok_mobile_common'),
          'Yкраїнська мова',
        );
      case 'en':
        return (Assets.icons.en.image(package: 'ok_mobile_common'), 'English');
      default:
        return (Assets.icons.pl.image(package: 'ok_mobile_common'), 'Polski');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context
        .watch<LocalizationCubit>()
        .state
        .currentLocale;
    return Column(
      children: [
        ...widget.locales.mapIndexed((index, locale) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.locales.length - 1 ? 8.0 : 0.0,
            ),
            child: IconTextButton(
              border: true,
              fontSize: 13,
              color: locale == currentLocale
                  ? AppColors.lightGreen
                  : AppColors.white,
              icon: localeData(locale).$1,
              onPressed: () {
                context.read<LocalizationCubit>().changeLocale(locale);
              },
              text: localeData(locale).$2,
              textColor: AppColors.black,
              trailingIcon: locale == currentLocale
                  ? Assets.icons.check.image(
                      package: 'ok_mobile_common',
                      color: AppColors.darkGreen,
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
