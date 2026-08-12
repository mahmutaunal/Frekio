import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  let frekioEngine = FlutterEngine(name: "frekio_engine")
  private(set) var frekioChannel: FlutterMethodChannel?
  private var playbackObservers: [NSObjectProtocol] = []

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    frekioEngine.run()
    GeneratedPluginRegistrant.register(with: frekioEngine)
    let channel = FlutterMethodChannel(
      name: "com.alpwarestudio.frekio/widget",
      binaryMessenger: frekioEngine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "update" {
        if let values = call.arguments as? [String: Any],
           let defaults = UserDefaults(suiteName: "group.com.alpwarestudio.frekio") {
          defaults.set(values["stationName"] as? String ?? "Frekio", forKey: "stationName")
          defaults.set(values["detail"] as? String ?? "", forKey: "detail")
          defaults.set(values["artworkUrl"] as? String ?? "", forKey: "artworkUrl")
          defaults.set(values["isPlaying"] as? Bool ?? false, forKey: "isPlaying")
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: "FrekioWidget")
          }
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    frekioChannel = channel
    playbackObservers = [
      NotificationCenter.default.addObserver(
        forName: .frekioTogglePlayback,
        object: nil,
        queue: .main
      ) { [weak self] _ in self?.sendPlaybackCommand("toggle") },
      NotificationCenter.default.addObserver(
        forName: .frekioStopPlayback,
        object: nil,
        queue: .main
      ) { [weak self] _ in self?.sendPlaybackCommand("stop") },
    ]
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func sendPlaybackCommand(_ method: String, argument: Any? = nil) {
    frekioChannel?.invokeMethod(method, arguments: argument)
  }

}
