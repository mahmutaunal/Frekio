import 'package:flutter_test/flutter_test.dart';
import 'package:frekio_radio/src/data/preferences_store.dart';
import 'package:frekio_radio/src/domain/station.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _station = Station(
  uuid: 'station-1',
  name: 'Frekio Test',
  streamUrl: 'https://example.com/live',
  homepage: '',
  favicon: '',
  tags: ['test'],
  countryCode: 'TR',
  state: 'Istanbul',
  language: 'Turkish',
  codec: 'MP3',
  bitrate: 128,
  votes: 1,
  clickCount: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('persists favorites and the last station', () async {
    final store = await PreferencesStore.create();
    await store.setFavorites([_station]);
    await store.setLastStation(_station);

    final restored = await PreferencesStore.create();
    expect(restored.favorites, hasLength(1));
    expect(restored.favorites.single.uuid, _station.uuid);
    expect(restored.lastStation?.name, _station.name);
  });

  test('limits recent history to thirty stations', () async {
    final store = await PreferencesStore.create();
    final stations = List.generate(
      35,
      (index) => Station.fromJson({
        'stationuuid': 'station-$index',
        'name': 'Station $index',
        'url_resolved': 'https://example.com/$index',
      }),
    );

    await store.setRecent(stations);

    expect(store.recent, hasLength(30));
    expect(store.recent.first.uuid, 'station-0');
    expect(store.recent.last.uuid, 'station-29');
  });

  test('ignores corrupt stored station data', () async {
    SharedPreferences.setMockInitialValues({'favorites.v1': 'not-json'});
    final store = await PreferencesStore.create();

    expect(store.favorites, isEmpty);
  });
}
