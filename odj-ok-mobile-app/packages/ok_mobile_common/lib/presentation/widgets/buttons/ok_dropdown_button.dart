part of '../../../ok_mobile_common.dart';

class OkDropdownButton extends StatefulWidget {
  const OkDropdownButton({
    required this.reasons,
    required this.onChanged,
    required this.value,
    this.hint,
    this.onReset,
    super.key,
  });

  final List<ActionReason> reasons;
  final ActionReason? value;
  final ValueChanged<ActionReason?> onChanged;
  final String? hint;
  final void Function()? onReset;

  @override
  State<OkDropdownButton> createState() => _OkDropdownButtonState();
}

class _OkDropdownButtonState extends State<OkDropdownButton> {
  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.hint != null) ...[
          Text(widget.hint!, style: AppTextStyle.smallItalic()),
          const SizedBox(height: 4),
        ],
        DropdownButtonHideUnderline(
          child: DropdownButton2<ActionReason>(
            items: widget.reasons
                .map(
                  (reason) => DropdownMenuItem<ActionReason>(
                    value: reason,
                    child: Text(
                      reason.label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.black),
                    ),
                  ),
                )
                .toList(),
            onChanged: widget.onChanged,
            onMenuStateChange: (isOpen) {
              setState(() {
                isMenuOpen = isOpen;
              });
            },
            value: widget.value,
            iconStyleData: IconStyleData(
              icon: widget.value != null && widget.onReset != null
                  ? GestureDetector(
                      onTap: widget.onReset,
                      child: Assets.icons.reset.image(
                        package: 'ok_mobile_common',
                        width: 16,
                      ),
                    )
                  : RotatedBox(
                      quarterTurns: 1,
                      child: Assets.icons.next.image(
                        package: 'ok_mobile_common',
                        width: 16,
                      ),
                    ),
              openMenuIcon: RotatedBox(
                quarterTurns: 3,
                child: Assets.icons.next.image(
                  package: 'ok_mobile_common',
                  width: 16,
                ),
              ),
            ),
            buttonStyleData: ButtonStyleData(
              height: 34,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                boxShadow: isMenuOpen
                    ? const [
                        BoxShadow(color: AppColors.white, offset: Offset(0, 8)),
                      ]
                    : null,
                border: Border.all(color: AppColors.darkGrey),
                borderRadius: BorderRadius.circular(8),
                color: widget.value != null
                    ? AppColors.lightGreen
                    : AppColors.white,
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 34,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return AppColors.lightGreen;
                }
                return null;
              }),
            ),
            dropdownStyleData: const DropdownStyleData(
              elevation: 0,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
