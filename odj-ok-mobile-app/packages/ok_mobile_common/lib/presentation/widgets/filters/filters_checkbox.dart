part of '../../../ok_mobile_common.dart';

class FiltersCheckbox extends StatefulWidget {
  const FiltersCheckbox({
    required this.onChanged,
    required this.text,
    required this.initialValue,
    this.activeBackgroundColor,
    this.uncheckedBorderColor,
    this.checkedForegroundColor,
    super.key,
  });

  factory FiltersCheckbox.pet({
    required ValueChanged<bool?> onChanged,
    required String text,
    required bool value,
    Key? key,
  }) {
    return FiltersCheckbox(
      activeBackgroundColor: AppColors.green,
      uncheckedBorderColor: AppColors.green,
      onChanged: onChanged,
      text: text,
      initialValue: value,
      key: key,
    );
  }

  factory FiltersCheckbox.can({
    required ValueChanged<bool?> onChanged,
    required String text,
    required bool value,
    Key? key,
  }) {
    return FiltersCheckbox(
      activeBackgroundColor: AppColors.black,
      uncheckedBorderColor: AppColors.black,
      onChanged: onChanged,
      text: text,
      initialValue: value,
      key: key,
    );
  }

  factory FiltersCheckbox.correct({
    required ValueChanged<bool?> onChanged,
    required String text,
    required bool value,
    Key? key,
  }) {
    return FiltersCheckbox(
      activeBackgroundColor: AppColors.lightGreen,
      uncheckedBorderColor: AppColors.black,
      checkedForegroundColor: AppColors.black,
      initialValue: value,
      onChanged: onChanged,
      text: text,
      key: key,
    );
  }

  factory FiltersCheckbox.canceled({
    required ValueChanged<bool?> onChanged,
    required String text,
    required bool value,
    Key? key,
  }) {
    return FiltersCheckbox(
      activeBackgroundColor: AppColors.powderRed,
      uncheckedBorderColor: AppColors.black,
      checkedForegroundColor: AppColors.black,
      initialValue: value,
      onChanged: onChanged,
      text: text,
      key: key,
    );
  }

  factory FiltersCheckbox.generic({
    required ValueChanged<bool?> onChanged,
    required String text,
    bool value = false,
    Key? key,
  }) {
    return FiltersCheckbox(
      activeBackgroundColor: AppColors.darkGreen,
      uncheckedBorderColor: AppColors.black,
      initialValue: value,
      onChanged: onChanged,
      text: text,
      key: key,
    );
  }

  final ValueChanged<bool?> onChanged;
  final String text;
  final bool initialValue;
  final Color? activeBackgroundColor;
  final Color? uncheckedBorderColor;
  final Color? checkedForegroundColor;

  @override
  State<FiltersCheckbox> createState() => _FiltersCheckboxState();
}

class _FiltersCheckboxState extends State<FiltersCheckbox> {
  bool _currentValue = false;

  @override
  void initState() {
    super.initState();

    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      avatar: _currentValue
          ? Assets.icons.checkSquare.image(
              package: 'ok_mobile_common',
              height: 18,
              color: widget.checkedForegroundColor ?? AppColors.lightGreen,
            )
          : Assets.icons.checkSquareEmpty.image(
              package: 'ok_mobile_common',
              height: 18,
              color: widget.uncheckedBorderColor ?? AppColors.black,
            ),
      label: Text(widget.text),
      labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: _currentValue
            ? widget.checkedForegroundColor ?? AppColors.white
            : AppColors.black,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      onPressed: () {
        setState(() {
          _currentValue = !_currentValue;
          widget.onChanged(_currentValue);
        });
      },
      backgroundColor: _currentValue
          ? widget.activeBackgroundColor
          : AppColors.grey,
    );
  }
}
