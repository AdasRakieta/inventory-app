part of '../../../../ok_mobile_scanner.dart';

class ScanManager {
  factory ScanManager() {
    return _instance;
  }

  ScanManager._internal();
  static final ScanManager _instance = ScanManager._internal();
  StreamSubscription<ScanResult>? _scanSubscription;
  Key? _currentKey;
  void Function(ScanResult)? _currentCallback;

  void startListening(
    Scanwedge scanwedge,
    Key key,
    void Function(ScanResult) onScan,
  ) {
    _scanSubscription?.cancel();
    _currentKey = key;
    _currentCallback = onScan;
    _scanSubscription = scanwedge.stream.listen((event) {
      if (_currentKey == key) {
        _currentCallback!(event);
      }
    });
  }

  void stopListening(Key key) {
    if (_currentKey == key) {
      _scanSubscription?.cancel();
      _scanSubscription = null;
      _currentKey = null;
      _currentCallback = null;
    }
  }
}
