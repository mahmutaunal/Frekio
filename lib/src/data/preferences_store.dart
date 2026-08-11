import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/station.dart';

class PreferencesStore {
  PreferencesStore._(this._prefs);

  final SharedPreferences _prefs;

  static const _favoritesKey = 'favorites.v1';
  static const _recentKey = 'recent.v1';
  static const _cacheKey = 'turkey_cache.v1';
  static const _cacheTimeKey = 'turkey_cache_time.v1';
  static const _localeKey = 'locale.v1';
  static const _themeKey = 'theme.v1';
  static const _lastStationKey = 'last_station.v1';

  static Future<PreferencesStore> create() async =>
      PreferencesStore._(await SharedPreferences.getInstance());

  List<Station> get favorites => _readStations(_favoritesKey);
  List<Station> get recent => _readStations(_recentKey);
  List<Station> get turkeyCache => _readStations(_cacheKey);
  Station? get lastStation {
    final stations = _readStations(_lastStationKey);
    return stations.isEmpty ? null : stations.first;
  }

  DateTime? get turkeyCacheTime {
    final raw = _prefs.getString(_cacheTimeKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  String get localeCode => _prefs.getString(_localeKey) ?? 'system';
  String get themeMode => _prefs.getString(_themeKey) ?? 'system';

  Future<void> setFavorites(List<Station> value) =>
      _writeStations(_favoritesKey, value);

  Future<void> setRecent(List<Station> value) =>
      _writeStations(_recentKey, value.take(30).toList(growable: false));

  Future<void> setLastStation(Station value) =>
      _writeStations(_lastStationKey, [value]);

  Future<void> setTurkeyCache(List<Station> value) async {
    await _writeStations(_cacheKey, value);
    await _prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }

  Future<void> setLocaleCode(String value) =>
      _prefs.setString(_localeKey, value);
  Future<void> setThemeMode(String value) => _prefs.setString(_themeKey, value);

  List<Station> _readStations(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Station.fromJson)
          .where((s) => s.uuid.isNotEmpty && s.streamUrl.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeStations(String key, List<Station> value) =>
      _prefs.setString(
        key,
        jsonEncode(value.map((e) => e.toJson()).toList(growable: false)),
      );
}
