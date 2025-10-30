part of '../../../../../ok_mobile_scanner.dart';

class DoubleScannerWidget extends StatefulWidget {
  const DoubleScannerWidget({
    required this.onScanFirstSuccess,
    required this.onScanSecondSuccess,
    required this.onClearFirst,
    required this.onClearSecond,
    required this.onManualInputFirst,
    required this.onManualInputSecond,
    required this.upperTitle,
    required this.upperTitle2,
    required this.upperWarning,
    required this.lowerTitle1,
    required this.lowerTitle2,
    required this.labelTextInputController,
    required this.sealTextInputController,
    this.isFailure = false,
    this.clearOnComplete = false,
    this.onInputCompleteResult,
    this.cameraCodeFormats,
    this.scannerCodeFormats,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  final void Function(String) onScanFirstSuccess;
  final void Function(String) onScanSecondSuccess;
  final void Function() onClearFirst;
  final void Function() onClearSecond;
  final void Function(String) onManualInputFirst;
  final void Function(String) onManualInputSecond;
  final String upperTitle;
  final String upperTitle2;
  final String upperWarning;
  final String lowerTitle1;
  final String lowerTitle2;
  final bool isFailure;
  final bool clearOnComplete;
  final bool? onInputCompleteResult;
  final List<BarcodeFormat>? cameraCodeFormats;
  final List<BarcodeConfig>? scannerCodeFormats;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController labelTextInputController;
  final TextEditingController sealTextInputController;

  @override
  State<DoubleScannerWidget> createState() => _DoubleScannerWidgetState();
}

//TODO get rid of setStates
class _DoubleScannerWidgetState extends State<DoubleScannerWidget> {
  bool _isLoading = false;
  final bool _cameraScannerEnabled = false;
  late PermissionStatus _status;
  late MobileScannerController _cameraScannerController;
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  DateTime _scannedCodeTime = DateTime.now();
  late List<BarcodeFormat> cameraCodeFormats;
  late List<BarcodeConfig> scannerCodeFormats;
  late TextEditingController _labelTextInputController;
  late TextEditingController _sealTextInputController;
  TextEditingController? _selectedTextInputController;
  late Scanwedge channel;
  late final Key _scannerKey;

  Future<void> requestPermissions() async {
    setState(() {
      _isLoading = true;
    });
    _status = await Permission.camera.request();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    final remoteConfiguration = context
        .read<DeviceConfigCubit>()
        .state
        .remoteConfiguration
        .mobileAppConfiguration;

    cameraCodeFormats =
        widget.cameraCodeFormats ?? remoteConfiguration.cameraCodeFormats;

    scannerCodeFormats =
        widget.scannerCodeFormats ?? remoteConfiguration.scannerCodeFormats;

    _scannerKey = widget.key ?? UniqueKey();
    initScanner();
    if (_cameraScannerEnabled) {
      requestPermissions();
      _cameraScannerController = MobileScannerController(
        detectionTimeoutMs: 2000,
        autoStart: false,
        formats: cameraCodeFormats,
      );
    }

    _labelTextInputController = widget.labelTextInputController;
    _sealTextInputController = widget.sealTextInputController;

    _labelTextInputController.addListener(() {
      if (_labelTextInputController.text.isNotEmpty && !focusNode1.hasFocus) {
        widget.onManualInputFirst(_labelTextInputController.text);
      }
    });
    _sealTextInputController.addListener(() {
      if (_sealTextInputController.text.isNotEmpty && !focusNode2.hasFocus) {
        widget.onManualInputSecond(_sealTextInputController.text);
      }
    });
    _selectedTextInputController = _labelTextInputController;
  }

  Future<void> initScanner() async {
    channel = await Scanwedge.getInstance();
    await channel.enableScanner();
    await channel.createScanProfile(
      ProfileModel(
        profileName: 'OkMobile',
        enabledBarcodes: scannerCodeFormats,
      ),
    );

    ScanManager().startListening(channel, _scannerKey, (ScanResult event) {
      final now = DateTime.now();
      final difference = now.difference(_scannedCodeTime);
      if (difference.inMilliseconds < 500) {
        return;
      }
      _scannedCodeTime = now;
      if (_selectedTextInputController == _labelTextInputController) {
        setState(() {
          _labelTextInputController.text = event.barcode;
          _selectedTextInputController = _sealTextInputController;
        });
        onScanFirst(event.barcode);
        return;
      } else if (_selectedTextInputController == _sealTextInputController) {
        setState(() {
          _sealTextInputController.text = event.barcode;
          _selectedTextInputController = null;
        });
        onScanSecond(event.barcode);
        return;
      }
    });
    setState(() {});
  }

  bool onScanFirst(String code) {
    widget.onScanFirstSuccess(code);
    if (_cameraScannerEnabled) {
      _cameraScannerController.dispose();
    }
    focusNode1.unfocus();
    return true;
  }

  bool onScanSecond(String code) {
    widget.onScanSecondSuccess(code);
    if (_cameraScannerEnabled) {
      _cameraScannerController.dispose();
    }
    focusNode2.unfocus();
    return true;
  }

  String _resolveUpperTitle() {
    if (_labelTextInputController.text.isNotEmpty &&
        _sealTextInputController.text.isNotEmpty) {
      return widget.upperWarning;
    } else if (_selectedTextInputController == _labelTextInputController) {
      return widget.upperTitle;
    } else if (_selectedTextInputController == _sealTextInputController) {
      return widget.upperTitle2;
    } else {
      return widget.upperTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : _cameraScannerEnabled && !_status.isGranted
          ? Text(S.current.camera_permission_denied)
          : Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: _cameraScannerEnabled ? 350 : null,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.grey,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 16,
                            child:
                                (_labelTextInputController.text.isNotEmpty &&
                                    _sealTextInputController.text.isNotEmpty)
                                ? Assets.icons.warning.image(
                                    package: 'ok_mobile_common',
                                  )
                                : Assets.icons.scan.image(
                                    package: 'ok_mobile_common',
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _resolveUpperTitle(),
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: AppColors.black,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const AppDivider(
                        color: AppColors.darkGrey,
                        verticalPadding: 8,
                      ),
                      // Temporarily disabled
                      // if (_cameraScannerEnabled) ...[

                      //   const SizedBox(
                      //     height: 8,
                      //   ),
                      //   Flexible(
                      //     child: Stack(
                      //       children: [
                      //         CameraScannerWrapper(
                      //           scannerController:
                      // _cameraScannerController,
                      //           onScan: (result) {
                      //             onScan(
                      //               result.barcodes.first.displayValue ??
                      //                   '',
                      //             );
                      //           },
                      //         ),
                      //         Container(
                      //           decoration: ShapeDecoration(
                      //             shape: CameraScannerOverlay(),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              widget.lowerTitle1,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.black,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          // Label Field
                          DoubleScannerCodeTextField(
                            key: ChangeBagLabelScreen.labelFieldKey,
                            focusNode: focusNode1,
                            clearOnFocus: true,
                            showDeleteIcon:
                                !_sealTextInputController.text.isNotEmpty &&
                                !focusNode2.hasFocus,
                            onClearInput: () {
                              _selectedTextInputController =
                                  _labelTextInputController;
                              widget.onClearFirst();
                            },
                            textInputController: _labelTextInputController,
                            isFailure: widget.isFailure,
                            clearOnComplete: widget.clearOnComplete,
                            onInputComplete: () {
                              if (_labelTextInputController.text.isEmpty) {
                                return false;
                              }
                              final result = onScanFirst(
                                _labelTextInputController.text,
                              );

                              return widget.onInputCompleteResult ?? result;
                            },
                            keyboardType: widget.keyboardType,
                            inputFormatters: widget.inputFormatters,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              widget.lowerTitle2,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.black,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          // SealField
                          DoubleScannerCodeTextField(
                            key: ChangeBagLabelScreen.sealFieldKey,
                            focusNode: focusNode2,
                            clearOnFocus: true,
                            showDeleteIcon: true,
                            enabled:
                                _labelTextInputController.text.isNotEmpty &&
                                !focusNode1.hasFocus,
                            onClearInput: () {
                              _selectedTextInputController =
                                  _sealTextInputController;
                              widget.onClearSecond();
                            },
                            textInputController: _sealTextInputController,
                            isFailure: widget.isFailure,
                            clearOnComplete: widget.clearOnComplete,
                            onInputComplete: () {
                              if (_sealTextInputController.text.isEmpty) {
                                return false;
                              }
                              final result = onScanSecond(
                                _sealTextInputController.text,
                              );

                              return widget.onInputCompleteResult ?? result;
                            },
                            keyboardType: widget.keyboardType,
                            inputFormatters: widget.inputFormatters,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    ScanManager().stopListening(_scannerKey);
    _labelTextInputController.dispose();
    _sealTextInputController.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    if (_cameraScannerEnabled) {
      _cameraScannerController.dispose();
    }
    super.dispose();
  }
}
