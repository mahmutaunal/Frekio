import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'data/preferences_store.dart';
import 'data/radio_browser_api.dart';
import 'domain/station.dart';
import 'services/radio_audio_handler.dart';
import 'services/platform_widget_bridge.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.api,
    required this.preferences,
    required this.audioHandler,
  });

  final RadioBrowserApi api;
  final PreferencesStore preferences;
  final RadioAudioHandler audioHandler;

  List<Station> popular = const [];
  List<Station> favorites = const [];
  List<Station> recent = const [];
  List<Station> searchResults = const [];
  bool loading = false;
  bool searching = false;
  String? errorMessage;
  String? liveTitle;
  Station? currentStation;
  PlaybackState playbackState = PlaybackState();

  Locale? locale;
  ThemeMode themeMode = ThemeMode.system;
  Duration? sleepTimerDuration;

  StreamSubscription<Station?>? _stationSub;
  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<String?>? _metadataSub;
  StreamSubscription<String>? _errorSub;
  int _searchGeneration = 0;

  Future<void> initialize() async {
    favorites = preferences.favorites;
    recent = preferences.recent;
    currentStation = audioHandler.currentStation;
    liveTitle = audioHandler.liveTitle;

    locale = switch (preferences.localeCode) {
      'tr' => const Locale('tr'),
      'en' => const Locale('en'),
      _ => null,
    };
    themeMode = switch (preferences.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _stationSub = audioHandler.stationStream.listen((station) {
      currentStation = station;
      recent = preferences.recent;
      _updatePlatformWidget();
      notifyListeners();
    });
    _metadataSub = audioHandler.metadataStream.listen((title) {
      liveTitle = title;
      _updatePlatformWidget();
      notifyListeners();
    });
    _playbackSub = audioHandler.playbackState.listen((state) {
      playbackState = state;
      _updatePlatformWidget();
      notifyListeners();
    });
    _errorSub = audioHandler.errorStream.listen((message) {
      errorMessage = message;
      notifyListeners();
    });

    await refreshPopular();
    _updatePlatformWidget();
  }

  bool isFavorite(Station station) =>
      favorites.any((item) => item.uuid == station.uuid);

  Future<void> toggleFavorite(Station station) async {
    final next = favorites.toList(growable: true);
    final index = next.indexWhere((item) => item.uuid == station.uuid);
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.insert(0, station);
    }
    favorites = List.unmodifiable(next);
    await preferences.setFavorites(favorites);
    notifyListeners();
  }

  Future<void> play(Station station) async {
    errorMessage = null;
    liveTitle = null;
    notifyListeners();
    await audioHandler.playStation(station);
    recent = preferences.recent;
    notifyListeners();
  }

  Future<void> togglePlayback() => audioHandler.toggle();

  Future<void> stop() => audioHandler.stop();

  Future<void> setSleepTimer(Duration? duration) async {
    sleepTimerDuration = duration;
    notifyListeners();
    await audioHandler.setSleepTimer(duration);
  }

  Future<void> refreshPopular({bool force = false}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cachedAt = preferences.turkeyCacheTime;
      final fresh =
          cachedAt != null &&
          DateTime.now().difference(cachedAt) < const Duration(hours: 6);

      if (!force && fresh && preferences.turkeyCache.isNotEmpty) {
        popular = preferences.turkeyCache;
      } else {
        popular = await api.popularTurkey();
        await preferences.setTurkeyCache(popular);
      }
    } catch (error) {
      if (preferences.turkeyCache.isNotEmpty) {
        popular = preferences.turkeyCache;
      } else {
        errorMessage = error.toString();
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query, {bool turkeyOnly = false}) async {
    final generation = ++_searchGeneration;
    searching = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await api.search(query, turkeyOnly: turkeyOnly);
      if (generation != _searchGeneration) return;
      searchResults = results;
    } catch (error) {
      if (generation != _searchGeneration) return;
      searchResults = const [];
      errorMessage = error.toString();
    } finally {
      if (generation == _searchGeneration) {
        searching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchGeneration += 1;
    searching = false;
    searchResults = const [];
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    locale = switch (code) {
      'tr' => const Locale('tr'),
      'en' => const Locale('en'),
      _ => null,
    };
    await preferences.setLocaleCode(code);
    notifyListeners();
  }

  Future<void> setTheme(String value) async {
    themeMode = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    await preferences.setThemeMode(value);
    notifyListeners();
  }

  void _updatePlatformWidget() {
    final station = currentStation;
    unawaited(
      PlatformWidgetBridge.update(
        stationName: station?.name,
        detail: liveTitle ?? station?.subtitle,
        artworkUrl: station?.favicon,
        isPlaying: playbackState.playing,
      ),
    );
  }

  @override
  void dispose() {
    _stationSub?.cancel();
    _playbackSub?.cancel();
    _metadataSub?.cancel();
    _errorSub?.cancel();
    unawaited(audioHandler.disposeHandler());
    api.dispose();
    super.dispose();
  }
}
