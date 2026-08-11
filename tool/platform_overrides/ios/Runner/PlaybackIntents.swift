import AppIntents
import Foundation

extension Notification.Name {
  static let frekioTogglePlayback = Notification.Name("FrekioTogglePlayback")
  static let frekioStopPlayback = Notification.Name("FrekioStopPlayback")
}

@available(iOS 17.0, *)
struct TogglePlaybackIntent: AudioPlaybackIntent {
  static let title: LocalizedStringResource = "Play or pause Frekio"
  static let description = IntentDescription("Controls the current Frekio station.")
  func perform() async throws -> some IntentResult {
    await MainActor.run { NotificationCenter.default.post(name: .frekioTogglePlayback, object: nil) }
    return .result()
  }
}

@available(iOS 17.0, *)
struct StopPlaybackIntent: AudioPlaybackIntent {
  static let title: LocalizedStringResource = "Stop Frekio"
  static let description = IntentDescription("Stops Internet radio playback.")
  func perform() async throws -> some IntentResult {
    await MainActor.run { NotificationCenter.default.post(name: .frekioStopPlayback, object: nil) }
    return .result()
  }
}
