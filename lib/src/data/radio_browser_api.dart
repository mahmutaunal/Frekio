import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../domain/station.dart';

class RadioBrowserException implements Exception {
  const RadioBrowserException(this.message);
  final String message;
  @override
  String toString() => message;
}

class RadioBrowserApi {
  RadioBrowserApi({HttpClient? client}) : _client = client ?? HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 8);
    _client.idleTimeout = const Duration(seconds: 15);
  }

  final HttpClient _client;
  final Random _random = Random.secure();
  List<String> _servers = const [];

  static const _userAgent = 'Frekio/1.3 (contact@alpwarestudio.com)';

  Future<List<Station>> popularTurkey({int limit = 120}) async {
    final query = {
      'countrycode': 'TR',
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
      'limit': '$limit',
    };
    return _stations('/json/stations/search', query);
  }

  Future<List<Station>> byTag(String tag, {int limit = 80}) async {
    final query = {
      'countrycode': 'TR',
      'tag': tag,
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
      'limit': '$limit',
    };
    return _stations('/json/stations/search', query);
  }

  Future<List<Station>> search(String term, {bool turkeyOnly = false}) async {
    final trimmed = term.trim();
    if (trimmed.length < 2) return const [];
    final query = {
      'name': trimmed,
      if (turkeyOnly) 'countrycode': 'TR',
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
      'limit': '100',
    };
    return _stations('/json/stations/search', query);
  }

  Future<void> reportClick(String stationUuid) async {
    if (stationUuid.isEmpty) return;
    try {
      await _requestJson('/json/url/$stationUuid', const {});
    } catch (_) {
      // Click reporting must never block playback.
    }
  }

  Future<List<Station>> _stations(
    String path,
    Map<String, String> query,
  ) async {
    final payload = await _requestJson(path, query);
    if (payload is! List) throw const RadioBrowserException('Invalid response');
    return payload
        .whereType<Map<String, dynamic>>()
        .map(Station.fromJson)
        .where(_isUsable)
        .toList(growable: false);
  }

  bool _isUsable(Station station) {
    final uri = Uri.tryParse(station.streamUrl);
    return station.uuid.isNotEmpty &&
        station.name.isNotEmpty &&
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http');
  }

  Future<dynamic> _requestJson(String path, Map<String, String> query) async {
    final servers = await _availableServers();
    Object? lastError;

    for (final server in servers) {
      try {
        final uri = Uri.https(server, path, query);
        final request = await _client
            .getUrl(uri)
            .timeout(const Duration(seconds: 8));
        request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close().timeout(
          const Duration(seconds: 10),
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException('HTTP ${response.statusCode}', uri: uri);
        }
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body);
      } catch (error) {
        lastError = error;
      }
    }
    _servers = const [];
    throw RadioBrowserException('Radio Browser unavailable: $lastError');
  }

  Future<List<String>> _availableServers() async {
    if (_servers.isNotEmpty) return List.unmodifiable(_servers);

    final discovered = <String>{};
    try {
      final addresses = await InternetAddress.lookup(
        'all.api.radio-browser.info',
      ).timeout(const Duration(seconds: 5));

      for (final address in addresses) {
        try {
          final reversed = await address.reverse().timeout(
            const Duration(seconds: 3),
          );
          final host = reversed.host.trim().toLowerCase();
          if (host.endsWith('.api.radio-browser.info')) {
            discovered.add(host);
          }
        } catch (_) {}
      }
    } catch (_) {}

    if (discovered.isEmpty) {
      // Resilient bootstrap hosts. They are fallbacks only; normal operation
      // discovers the current server pool via DNS as Radio Browser recommends.
      discovered.addAll({
        'de1.api.radio-browser.info',
        'de2.api.radio-browser.info',
        'fi1.api.radio-browser.info',
      });
    }

    final list = discovered.toList()..shuffle(_random);
    _servers = list;
    return List.unmodifiable(_servers);
  }

  void dispose() => _client.close(force: true);
}
