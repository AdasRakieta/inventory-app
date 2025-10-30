part of '../../../../../ok_mobile_scanner.dart';

class CodeTextField extends StatefulWidget {
  const CodeTextField({
    required this.textInputController,
    required this.onInputComplete,
    this.isFailure = false,
    this.autoFocus = false,
    this.clearOnComplete = false,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController textInputController;
  final Future<bool> Function() onInputComplete;
  final bool autoFocus;
  final bool clearOnComplete;
  final bool enabled;
  final bool isFailure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<CodeTextField> createState() => _CodeTextFieldState();
}

class _CodeTextFieldState extends State<CodeTextField> {
  bool _isEditingComplete = false;

  @override
  void initState() {
    super.initState();
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
        enabled: widget.enabled,
        controller: widget.textInputController,
        style: Theme.of(
          context,
        ).textTheme.labelMedium!.copyWith(color: AppColors.darkGreen),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          fillColor: _isEditingComplete
              ? AppColors.lightGreen
              : AppColors.white,
          suffixIconConstraints: const BoxConstraints(maxHeight: 16),
          suffixIcon: _isEditingComplete
              ? null
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
        onChanged: (value) {
          if (_isEditingComplete) {
            setState(() {
              _isEditingComplete = false;
            });
          }
        },
      ),
    );
  }

  Future<void> _onEditingComplete() async {
    if (widget.textInputController.text.isEmpty) return;
    final result = await widget.onInputComplete();

    if (result) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isEditingComplete = true;
        });
      });
    }

    if (result && widget.clearOnComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 250), () {
          widget.textInputController.clear();
          if (mounted) {
            setState(() {
              _isEditingComplete = false;
            });
          }
        });
      });
      return;
    }

    if (widget.clearOnComplete) {
      widget.textInputController.clear();
    }
  }
}
