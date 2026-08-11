import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frekio_radio/src/l10n/strings.dart';

void main() {
  test('provides Turkish and English product strings', () {
    expect(S(const Locale('tr')).favorites, 'Favoriler');
    expect(S(const Locale('en')).favorites, 'Favorites');
    expect(S(const Locale('tr')).minutes(30), '30 dakika');
    expect(S(const Locale('en')).minutes(30), '30 minutes');
  });
}
