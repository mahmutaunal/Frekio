import 'dart:io';

import 'package:flutter/services.dart';

import 'radio_audio_handler.dart';

class PlatformWidgetBridge {
  const PlatformWidgetBridge._();

  static const _channel = MethodChannel('com.alpwarestudio.frekio/widget');

  static void bind(RadioAudioHandler audioHandler) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'playMediaId':
          final mediaId = call.arguments?.toString() ?? '';
          if (mediaId.isNotEmpty) await audioHandler.playFromMediaId(mediaId);
        case 'toggle':
          await audioHandler.toggle();
        case 'stop':
          await audioHandler.stop();
      }
    });
  }

  static Future<void> update({
    required String? stationName,
    required String? detail,
    required String? artworkUrl,
    required bool isPlaying,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('update', {
        'stationName': stationName ?? 'Frekio',
        'detail': detail ?? '',
        'artworkUrl': artworkUrl ?? '',
        'isPlaying': isPlaying,
      });
    } on MissingPluginException {
      // Widget support is unavailable on this build target.
    } on PlatformException {
      // A launcher/widget failure must never interrupt playback.
    }
  }
}
