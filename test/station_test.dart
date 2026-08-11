import 'package:flutter_test/flutter_test.dart';
import 'package:frekio_radio/src/domain/station.dart';

void main() {
  group('Station', () {
    test('parses Radio Browser fields', () {
      final station = Station.fromJson({
        'stationuuid': 'abc',
        'name': ' Test  Radio ',
        'url_resolved': 'https://example.com/live',
        'homepage': '',
        'favicon': '',
        'tags': 'pop, turkish, pop',
        'countrycode': 'tr',
        'state': 'Istanbul',
        'language': 'Turkish',
        'codec': 'MP3',
        'bitrate': 128,
        'votes': 42,
        'clickcount': 100,
      });

      expect(station.uuid, 'abc');
      expect(station.name, 'Test Radio');
      expect(station.countryCode, 'TR');
      expect(station.tags, ['pop', 'turkish']);
      expect(station.bitrate, 128);
    });

    test('falls back to url when url_resolved is missing', () {
      final station = Station.fromJson({
        'stationuuid': 'fallback',
        'name': 'Fallback Radio',
        'url': 'http://example.com/live',
        'tags': '',
      });

      expect(station.streamUrl, 'http://example.com/live');
      expect(station.tags, isEmpty);
      expect(station.bitrate, 0);
    });

    test('normalizes whitespace in display strings', () {
      final station = Station.fromJson({
        'stationuuid': 'space',
        'name': '  Radio   Name  ',
        'url_resolved': 'https://example.com/live',
        'state': '  New   York ',
      });

      expect(station.name, 'Radio Name');
      expect(station.state, 'New York');
    });
  });
}
