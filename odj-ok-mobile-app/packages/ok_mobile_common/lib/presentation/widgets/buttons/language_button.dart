part of '../../../ok_mobile_common.dart';

class LanguageButton extends StatefulWidget {
  const LanguageButton({
    required this.initialLocale,
    required this.onLanguageChange,
    super.key,
  });

  final Locale initialLocale;
  final void Function(Locale locale) onLanguageChange;

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  int _selectedLocale = 0;

  void setInitialLanguage() {
    _selectedLocale = AppLocales.locales.indexWhere(
      (locale) => locale == widget.initialLocale,
    );
    if (_selectedLocale == -1) {
      _selectedLocale = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    setInitialLanguage();
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        buttonStyleData: ButtonStyleData(
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          width: 70,
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down),
        ),
        items: List.generate(
          AppLocales.locales.length,
          (index) => DropdownMenuItem(
            value: index,
            child: Text(
              AppLocales.locales[index].languageCode.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: AppColors.black),
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _selectedLocale = value ?? 0;
            widget.onLanguageChange(
              Locale(AppLocales.locales[_selectedLocale].languageCode),
            );
          });
        },
        value: _selectedLocale,
      ),
    );
  }
}
