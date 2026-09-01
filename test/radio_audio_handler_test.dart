import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frekio_radio/src/services/radio_audio_handler.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  group('Android Auto playback state', () {
    test('keeps a stopped station resumable', () {
      expect(
        carCompatibleProcessingState(
          playerState: ProcessingState.idle,
          hasPlayableStation: true,
        ),
        AudioProcessingState.ready,
      );
    });

    test('keeps a genuinely empty player idle', () {
      expect(
        carCompatibleProcessingState(
          playerState: ProcessingState.idle,
          hasPlayableStation: false,
        ),
        AudioProcessingState.idle,
      );
    });

    test('preserves active player processing states', () {
      const cases = {
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      };

      for (final entry in cases.entries) {
        expect(
          carCompatibleProcessingState(
            playerState: entry.key,
            hasPlayableStation: true,
          ),
          entry.value,
        );
      }
    });
  });
}
