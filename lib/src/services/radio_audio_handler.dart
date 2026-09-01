import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../data/preferences_store.dart';
import '../data/radio_browser_api.dart';
import '../domain/station.dart';

class RadioAudioHandler extends BaseAudioHandler with QueueHandler {
  RadioAudioHandler({
    required RadioBrowserApi api,
    required PreferencesStore preferences,
  }) : _api = api,
       _preferences = preferences {
    unawaited(_init());
  }

  final RadioBrowserApi _api;
  final PreferencesStore _preferences;
  final AudioPlayer _player = AudioPlayer(
    handleInterruptions: true,
    handleAudioSessionActivation: true,
    androidApplyAudioAttributes: true,
  );

  final _stationController = StreamController<Station?>.broadcast();
  final _metadataController = StreamController<String?>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Timer? _sleepTimer;
  Timer? _pausedIdleTimer;
  Timer? _reconnectTimer;
  Station? _currentStation;
  String? _liveTitle;
  bool _wantsPlayback = false;
  bool _reconnecting = false;
  int _reconnectAttempt = 0;
  final Map<String, Station> _mediaIndex = <String, Station>{};
  final Completer<void> _ready = Completer<void>();

  Stream<Station?> get stationStream => _stationController.stream;
  Stream<String?> get metadataStream => _metadataController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Station? get currentStation => _currentStation;
  String? get liveTitle => _liveTitle;
  Future<void> get ready => _ready.future;

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      final restoredStation = _preferences.lastStation;
      if (restoredStation != null) {
        _currentStation = restoredStation;
        _mediaIndex[restoredStation.uuid] = restoredStation;
        _publishMediaItem();
      }

      _player.playbackEventStream.listen(
        _broadcastState,
        onError: (Object error, StackTrace stackTrace) {
          _errorController.add(error.toString());
        },
      );

      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.ready) {
          _reconnectAttempt = 0;
          _reconnecting = false;
        } else if (state == ProcessingState.completed) {
          unawaited(stop());
        }
      });

      _player.icyMetadataStream.listen((metadata) {
        final title = metadata?.info?.title?.trim();
        final normalized = (title == null || title.isEmpty) ? null : title;
        if (normalized == _liveTitle) return;
        _liveTitle = normalized;
        _metadataController.add(normalized);
        _publishMediaItem();
      });

      _player.errorStream.listen((error) {
        _errorController.add(error.message ?? error.toString());
        _scheduleReconnect();
      });
      if (!_ready.isCompleted) _ready.complete();
    } catch (error, stackTrace) {
      if (!_ready.isCompleted) _ready.completeError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> playStation(Station station) async {
    _cancelReconnect();
    _wantsPlayback = true;

    if (_currentStation?.uuid == station.uuid &&
        _player.processingState != ProcessingState.idle) {
      await play();
      return;
    }

    _currentStation = station;
    _liveTitle = null;
    _stationController.add(station);
    _metadataController.add(null);
    _mediaIndex[station.uuid] = station;
    _publishMediaItem();

    await _rememberRecent(station);
    await _preferences.setLastStation(station);
    unawaited(_api.reportClick(station.uuid));

    try {
      await _loadAndPlay(station);
    } catch (error) {
      _errorController.add('Unable to play ${station.name}: $error');
      _scheduleReconnect();
    }
  }

  Future<void> _loadAndPlay(Station station) async {
    await _player.stop();
    await _player.setUrl(station.streamUrl);
    if (_wantsPlayback) _startPlayback();
  }

  void _startPlayback() {
    unawaited(
      _player.play().catchError((Object error, StackTrace stackTrace) {
        if (!_wantsPlayback) return;
        _errorController.add(error.toString());
        _scheduleReconnect();
      }),
    );
  }

  @override
  Future<void> play() async {
    _wantsPlayback = true;
    _pausedIdleTimer?.cancel();
    _cancelReconnect();

    if (_player.processingState == ProcessingState.idle &&
        _currentStation != null) {
      try {
        await _loadAndPlay(_currentStation!);
      } catch (error) {
        _errorController.add(error.toString());
        _scheduleReconnect();
      }
      return;
    }
    // AudioPlayer.play() completes only after playback is paused, stopped, or
    // completed. A media-session command must return as soon as playback has
    // been started, otherwise Android Auto can treat the command as stalled.
    _startPlayback();
  }

  @override
  Future<void> pause() async {
    _wantsPlayback = false;
    _cancelReconnect();
    await _player.pause();
    _pausedIdleTimer?.cancel();
    _pausedIdleTimer = Timer(const Duration(minutes: 5), stop);
  }

  @override
  Future<void> stop() async {
    _wantsPlayback = false;
    _sleepTimer?.cancel();
    _pausedIdleTimer?.cancel();
    _cancelReconnect();
    _reconnectAttempt = 0;
    await _player.stop();
    // Do not call BaseAudioHandler.stop(). It publishes
    // AudioProcessingState.idle, which audio_service maps to STATE_NONE on
    // Android. Android Auto disables the playback UI in that state, so a later
    // Play command cannot reliably resume the station. just_audio's stop()
    // releases its native resources while retaining the source for resumption.
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await pause();
    } else if (_currentStation != null) {
      await play();
    }
  }

  @override
  Future<void> skipToNext() => _skipStation(1);

  @override
  Future<void> skipToPrevious() => _skipStation(-1);

  Future<void> _skipStation(int direction) async {
    final station = _currentStation;
    final candidates = <Station>[];
    final seen = <String>{};
    for (final item in [..._preferences.recent, ..._preferences.favorites]) {
      if (seen.add(item.uuid)) candidates.add(item);
    }
    if (station == null || candidates.length < 2) return;
    final currentIndex = candidates.indexWhere(
      (item) => item.uuid == station.uuid,
    );
    final baseIndex = currentIndex < 0 ? 0 : currentIndex;
    final nextIndex = (baseIndex + direction) % candidates.length;
    await playStation(candidates[nextIndex]);
  }

  Future<void> setSleepTimer(Duration? duration) async {
    _sleepTimer?.cancel();
    if (duration == null) return;
    _sleepTimer = Timer(duration, stop);
  }

  void _scheduleReconnect() {
    if (!_wantsPlayback || _currentStation == null || _reconnecting) return;
    if (_reconnectAttempt >= 3) return;

    const delays = <Duration>[
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
    ];
    final delay = delays[_reconnectAttempt];
    _reconnectAttempt += 1;
    _reconnecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      _reconnecting = false;
      if (!_wantsPlayback || _currentStation == null) return;
      try {
        await _loadAndPlay(_currentStation!);
      } catch (error) {
        _errorController.add(error.toString());
        _scheduleReconnect();
      }
    });
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnecting = false;
  }

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    if (parentMediaId == AudioService.browsableRootId) {
      final tr = Platform.localeName.toLowerCase().startsWith('tr');
      return [
        MediaItem(
          id: 'favorites',
          title: tr ? 'Favoriler' : 'Favorites',
          playable: false,
        ),
        MediaItem(
          id: 'recent',
          title: tr ? 'Son dinlenenler' : 'Recent',
          playable: false,
        ),
        MediaItem(
          id: 'popular_tr',
          title: tr ? 'Türkiye' : 'Turkey',
          playable: false,
        ),
      ];
    }

    if (parentMediaId == 'favorites') {
      final stations = _preferences.favorites;
      _indexStations(stations);
      return stations.map(_toMediaItem).toList(growable: false);
    }
    if (parentMediaId == 'recent') {
      final stations = _preferences.recent;
      _indexStations(stations);
      return stations.map(_toMediaItem).toList(growable: false);
    }
    if (parentMediaId == 'popular_tr') {
      final stations = await _api.popularTurkey(limit: 60);
      _indexStations(stations);
      return stations.map(_toMediaItem).toList(growable: false);
    }

    return const [];
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    final indexed = _mediaIndex[mediaId];
    if (indexed != null) {
      await playStation(indexed);
      return;
    }

    final known = [
      ..._preferences.favorites,
      ..._preferences.recent,
    ].where((s) => s.uuid == mediaId).firstOrNull;

    if (known != null) await playStation(known);
  }

  @override
  Future<void> playFromSearch(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      final fallback =
          _preferences.recent.firstOrNull ?? _preferences.favorites.firstOrNull;
      if (fallback != null) await playStation(fallback);
      return;
    }
    try {
      final matches = await _api.search(normalized);
      final station = matches.firstOrNull;
      if (station != null) await playStation(station);
    } catch (error) {
      _errorController.add(error.toString());
    }
  }

  void _indexStations(Iterable<Station> stations) {
    for (final station in stations) {
      _mediaIndex[station.uuid] = station;
    }
  }

  void _publishMediaItem() {
    final station = _currentStation;
    if (station == null) return;
    mediaItem.add(_toMediaItem(station, liveTitle: _liveTitle));
  }

  MediaItem _toMediaItem(Station station, {String? liveTitle}) => MediaItem(
    id: station.uuid,
    title: liveTitle ?? station.name,
    album: station.name,
    artist: liveTitle == null ? station.tags.take(2).join(' • ') : station.name,
    artUri: station.favicon.trim().isEmpty
        ? null
        : Uri.tryParse(station.favicon.trim()),
    playable: true,
    isLive: true,
    extras: {
      'streamUrl': station.streamUrl,
      'favicon': station.favicon,
      'liveTitle': ?liveTitle,
    },
  );

  Future<void> _rememberRecent(Station station) async {
    final current = _preferences.recent
        .where((s) => s.uuid != station.uuid)
        .toList(growable: true);
    current.insert(0, station);
    await _preferences.setRecent(current);
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = carCompatibleProcessingState(
      playerState: _player.processingState,
      hasPlayableStation: _currentStation != null,
    );

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.skipToPrevious,
          MediaAction.skipToNext,
          MediaAction.stop,
        },
        processingState: processingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!_player.playing) await stop();
  }

  Future<void> disposeHandler() async {
    _sleepTimer?.cancel();
    _pausedIdleTimer?.cancel();
    _cancelReconnect();
    await _stationController.close();
    await _metadataController.close();
    await _errorController.close();
    await _player.dispose();
  }
}

/// Maps the player lifecycle to a media-session lifecycle that remains
/// resumable from Android Auto.
///
/// An idle player with a remembered station is stopped, not empty. Exposing it
/// as [AudioProcessingState.ready] produces Android's paused state and keeps
/// the Play action available. A genuinely empty player remains idle.
AudioProcessingState carCompatibleProcessingState({
  required ProcessingState playerState,
  required bool hasPlayableStation,
}) => switch (playerState) {
  ProcessingState.idle =>
    hasPlayableStation ? AudioProcessingState.ready : AudioProcessingState.idle,
  ProcessingState.loading => AudioProcessingState.loading,
  ProcessingState.buffering => AudioProcessingState.buffering,
  ProcessingState.ready => AudioProcessingState.ready,
  ProcessingState.completed => AudioProcessingState.completed,
};

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
