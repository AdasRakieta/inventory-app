part of '../../ok_mobile_scanner.dart';

class CameraScannerWrapper extends StatefulWidget {
  const CameraScannerWrapper({
    required this.onScan,
    required this.scannerController,
    super.key,
  });

  final void Function(BarcodeCapture) onScan;
  final MobileScannerController scannerController;

  @override
  State<CameraScannerWrapper> createState() => _CameraScannerWrapperState();
}

class _CameraScannerWrapperState extends State<CameraScannerWrapper>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;

  Future<void> ensureCameraInitialized() async {
    _scannerController = widget.scannerController;

    if (!_scannerController.value.isInitialized ||
        !_scannerController.value.isRunning) {
      await _scannerController.start();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ensureCameraInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: widget.onScan,
      controller: _scannerController,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController.start();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _scannerController.stop();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _asyncStop();
    super.dispose();
  }

  Future<void> _asyncStop() async {
    await _scannerController.stop();
    await _scannerController.dispose();
  }
}
