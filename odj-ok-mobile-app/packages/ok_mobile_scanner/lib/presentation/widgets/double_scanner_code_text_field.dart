part of '../../../../../ok_mobile_scanner.dart';

class DoubleScannerCodeTextField extends StatefulWidget {
  const DoubleScannerCodeTextField({
    required this.textInputController,
    required this.onInputComplete,
    this.onClearInput,
    this.isFailure = false,
    this.autoFocus = false,
    this.clearOnComplete = false,
    this.enabled = true,
    this.showDeleteIcon = false,
    this.clearOnFocus = false,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController textInputController;
  final bool Function() onInputComplete;
  final void Function()? onClearInput;
  final bool autoFocus;
  final bool clearOnComplete;
  final bool enabled;
  final bool isFailure;
  final bool showDeleteIcon;
  final bool clearOnFocus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<DoubleScannerCodeTextField> createState() =>
      DoubleScannerCodeTextFieldState();
}

class DoubleScannerCodeTextFieldState
    extends State<DoubleScannerCodeTextField> {
  bool _isEditingComplete = false;

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(() {
      if (focusNode.hasFocus && widget.clearOnFocus) {
        widget.onClearInput?.call();
        widget.textInputController.clear();
        _isEditingComplete = false;
      }
      setState(() {});
    });
    widget.textInputController.addListener(() {
      setState(() {
        if (widget.textInputController.text.isNotEmpty && !focusNode.hasFocus) {
          _isEditingComplete = true;
        }
      });
    });
  }

  void clearInput() {
    setState(() {
      widget.onClearInput?.call();
      _isEditingComplete = false;
      widget.textInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFailure) {
      setState(() {
        _isEditingComplete = false;
      });
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: TextField(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        focusNode: focusNode,
        enabled: widget.enabled,
        controller: widget.textInputController,
        style: Theme.of(
          context,
        ).textTheme.labelMedium!.copyWith(color: AppColors.darkGreen),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkGrey),
          ),
          fillColor: !widget.enabled
              ? AppColors.grey
              : !focusNode.hasFocus &&
                    widget.textInputController.text.isNotEmpty
              ? AppColors.lightGreen
              : AppColors.white,
          suffixIconConstraints: const BoxConstraints(maxHeight: 16),
          suffixIcon: _isEditingComplete
              ? widget.showDeleteIcon
                    ? GestureDetector(
                        onTap: clearInput,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Assets.icons.reset.image(
                            package: 'ok_mobile_common',
                          ),
                        ),
                      )
                    : null
              : GestureDetector(
                  onTap: _onEditingComplete,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Assets.icons.next.image(package: 'ok_mobile_common'),
                  ),
                ),
        ),
        onEditingComplete: _onEditingComplete,
        autofocus: widget.autoFocus,
      ),
    );
  }

  void _onEditingComplete() {
    if (widget.textInputController.text.isEmpty) return;
    final result = widget.onInputComplete();
    if (widget.clearOnComplete) {
      widget.textInputController.clear();
    }
    if (result) {
      setState(() {
        _isEditingComplete = true;
        focusNode.unfocus();
      });
    }
  }
}
