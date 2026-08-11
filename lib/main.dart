import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/app_state.dart';
import 'src/data/preferences_store.dart';
import 'src/data/radio_browser_api.dart';
import 'src/services/radio_audio_handler.dart';
import 'src/services/platform_widget_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final preferences = await PreferencesStore.create();
  final api = RadioBrowserApi();

  final audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(api: api, preferences: preferences),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.alpwarestudio.frekio.audio',
      androidNotificationChannelName: 'Frekio playback',
      androidNotificationChannelDescription: 'Internet radio playback controls',
      androidNotificationIcon: 'drawable/ic_stat_radio',
      notificationColor: Color(0xFF5D5BE6),
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidBrowsableRootExtras: {
        'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
        'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
      },
      artDownscaleWidth: 768,
      artDownscaleHeight: 768,
    ),
  );
  await audioHandler.ready;
  PlatformWidgetBridge.bind(audioHandler);

  final state = AppState(
    api: api,
    preferences: preferences,
    audioHandler: audioHandler,
  );
  await state.initialize();

  runApp(FrekioApp(state: state));
}
