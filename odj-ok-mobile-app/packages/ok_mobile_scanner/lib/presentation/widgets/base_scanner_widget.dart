part of '../../../../../ok_mobile_scanner.dart';

class BaseScannerWidget extends StatefulWidget {
  const BaseScannerWidget({
    required this.onScanSuccess,
    required this.upperTitle,
    required this.lowerTitle,
    this.isFailure = false,
    this.clearOnComplete = false,
    this.onInputCompleteResult,
    this.cameraCodeFormats,
    this.scannerCodeFormats,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  final Future<bool> Function(String) onScanSuccess;
  final String upperTitle;
  final String lowerTitle;
  final bool isFailure;
  final bool clearOnComplete;
  final bool? onInputCompleteResult;
  final List<BarcodeFormat>? cameraCodeFormats;
  final List<BarcodeConfig>? scannerCodeFormats;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<BaseScannerWidget> createState() => _BaseScannerWidgetState();
}

class _BaseScannerWidgetState extends State<BaseScannerWidget> {
  bool _isLoading = false;
  final bool _cameraScannerEnabled = false;
  late PermissionStatus _status;
  late MobileScannerController _cameraScannerController;
  late TextEditingController _textInputController;
  late List<BarcodeFormat> cameraCodeFormats;
  late List<BarcodeConfig> scannerCodeFormats;
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
    _textInputController = TextEditingController();
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
      onScan(event.barcode);
    });
  }

  Future<bool> onScan(String code) async {
    return widget.onScanSuccess(code);
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
                            child: Assets.icons.scan.image(
                              package: 'ok_mobile_common',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.upperTitle,
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
                      if (_cameraScannerEnabled) ...[
                        const SizedBox(height: 8),
                        Flexible(
                          child: Stack(
                            children: [
                              CameraScannerWrapper(
                                scannerController: _cameraScannerController,
                                onScan: (result) {
                                  onScan(
                                    result.barcodes.first.displayValue ?? '',
                                  );
                                },
                              ),
                              Container(
                                decoration: ShapeDecoration(
                                  shape: CameraScannerOverlay(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              widget.lowerTitle,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.black,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          CodeTextField(
                            textInputController: _textInputController,
                            isFailure: widget.isFailure,
                            clearOnComplete: widget.clearOnComplete,
                            onInputComplete: () async {
                              if (_textInputController.text.isEmpty) {
                                return false;
                              }
                              final result = await onScan(
                                _textInputController.text,
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
    _textInputController.dispose();
    if (_cameraScannerEnabled) {
      _cameraScannerController.dispose();
    }
    super.dispose();
  }
}
