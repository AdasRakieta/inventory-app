part of '../ok_mobile_common.dart';

class AudioHelper {
  factory AudioHelper() => _instance;

  AudioHelper._internal();

  Uint8List? _bytes;

  static final AudioHelper _instance = AudioHelper._internal();

  Future<void> play() async {
    if (_bytes == null) {
      final byteData = await rootBundle.load(
        'packages/ok_mobile_common/assets/sounds/error.mp3',
      );
      _bytes = byteData.buffer.asUint8List();
      await AudioPlayer().play(BytesSource(_bytes!));
    } else {
      await AudioPlayer().play(BytesSource(_bytes!));
    }
  }
}
