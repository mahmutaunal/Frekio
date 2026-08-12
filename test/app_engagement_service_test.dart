import 'package:flutter_test/flutter_test.dart';
import 'package:frekio_radio/src/services/app_engagement_service.dart';

void main() {
  group('isNewerVersion', () {
    test('detects newer semantic versions', () {
      expect(isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(isNewerVersion('2.0.0', '1.9.9'), isTrue);
    });

    test('does not treat equal or older versions as updates', () {
      expect(isNewerVersion('1.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.2.9', '1.3.0'), isFalse);
    });
  });
}
