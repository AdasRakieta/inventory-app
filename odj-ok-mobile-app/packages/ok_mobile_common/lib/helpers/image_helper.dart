part of '../ok_mobile_common.dart';

class ImageHelper {
  ImageHelper._();

  static Future<void> precacheIcons(BuildContext context) async {
    for (final icon in Assets.icons.values) {
      await _preloadImage(icon.provider(package: 'ok_mobile_common'));
    }
  }

  static Future<void> _preloadImage(ImageProvider provider) async {
    const configuration = ImageConfiguration.empty;
    final completer = Completer<void>();
    final imageStream = provider.resolve(configuration);

    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete();
    });

    imageStream.addListener(listener);
    try {
      await completer.future;
    } finally {
      imageStream.removeListener(listener);
    }
  }
}
