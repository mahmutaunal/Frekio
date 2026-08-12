import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'src/app.dart';
import 'src/app_state.dart';
import 'src/data/preferences_store.dart';
import 'src/data/radio_browser_api.dart';
import 'src/services/radio_audio_handler.dart';
import 'src/services/platform_widget_bridge.dart';
import 'src/services/app_engagement_service.dart';
import 'src/services/notification_permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final preferences = await PreferencesStore.create();
  final packageInfo = await PackageInfo.fromPlatform();
  final api = RadioBrowserApi(
    userAgent: 'Frekio/${packageInfo.version} (contact@alpwarestudio.com)',
  );

  final audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(api: api, preferences: preferences),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.alpwarestudio.frekio.audio',
      androidNotificationChannelName: 'Media playback',
      androidNotificationChannelDescription:
          'Now playing artwork and playback controls',
      androidNotificationIcon: 'drawable/ic_stat_radio',
      notificationColor: Color(0xFF5D5BE6),
      androidNotificationOngoing: false,
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
    engagement: AppEngagementService(preferences),
    notificationPermission: const NotificationPermissionService(),
  );
  await state.initialize();

  runApp(FrekioApp(state: state));
}
