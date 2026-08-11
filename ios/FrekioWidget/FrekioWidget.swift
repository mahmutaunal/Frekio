import AppIntents
import SwiftUI
import WidgetKit

private struct FrekioEntry: TimelineEntry {
  let date: Date
  let stationName: String
  let detail: String
  let isPlaying: Bool
  let artworkData: Data?
}

private struct FrekioProvider: TimelineProvider {
  func placeholder(in context: Context) -> FrekioEntry {
    FrekioEntry(
      date: Date(),
      stationName: "Frekio",
      detail: "Live radio",
      isPlaying: false,
      artworkData: nil
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (FrekioEntry) -> Void) {
    Task { completion(await entry(loadArtwork: !context.isPreview)) }
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<FrekioEntry>) -> Void) {
    Task {
      let value = await entry(loadArtwork: true)
      completion(Timeline(entries: [value], policy: .never))
    }
  }

  private func entry(loadArtwork: Bool) async -> FrekioEntry {
    let defaults = UserDefaults(suiteName: "group.com.alpwarestudio.frekio")
    let artworkURL = defaults?.string(forKey: "artworkUrl") ?? ""
    var artworkData: Data?
    if loadArtwork,
       let url = URL(string: artworkURL),
       let (data, response) = try? await URLSession.shared.data(from: url),
       let http = response as? HTTPURLResponse,
       (200..<300).contains(http.statusCode),
       data.count <= 3_000_000 {
      artworkData = data
    }
    return FrekioEntry(
      date: Date(),
      stationName: defaults?.string(forKey: "stationName") ?? "Frekio",
      detail: defaults?.string(forKey: "detail") ?? "Live radio",
      isPlaying: defaults?.bool(forKey: "isPlaying") ?? false,
      artworkData: artworkData
    )
  }
}

private struct FrekioWidgetView: View {
  let entry: FrekioEntry

  var body: some View {
    HStack(spacing: 13) {
      artwork
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 5) {
          Circle()
            .fill(.green)
            .frame(width: 6, height: 6)
          Text("FREKIO  •  LIVE")
            .font(.caption2.weight(.bold))
            .tracking(0.35)
            .foregroundStyle(.white.opacity(0.72))
        }
        Text(entry.stationName)
          .font(.headline.weight(.bold))
          .foregroundStyle(.white)
          .lineLimit(1)
        Text(entry.detail.isEmpty ? "Live radio" : entry.detail)
          .font(.caption)
          .foregroundStyle(.white.opacity(0.7))
          .lineLimit(1)
      }

      Spacer(minLength: 2)

      HStack(spacing: 8) {
        Button(intent: StopPlaybackIntent()) {
          Image(systemName: "stop.fill")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white.opacity(0.84))
            .frame(width: 36, height: 36)
            .background(.white.opacity(0.1), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Stop")

        Button(intent: TogglePlaybackIntent()) {
          Image(systemName: entry.isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background(
              LinearGradient(
                colors: [Color(red: 0.52, green: 0.5, blue: 1), Color(red: 0.35, green: 0.32, blue: 0.88)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
              in: Circle()
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.isPlaying ? "Pause" : "Play")
      }
    }
    .containerBackground(for: .widget) {
      LinearGradient(
        colors: [Color(red: 0.16, green: 0.15, blue: 0.25), Color(red: 0.055, green: 0.05, blue: 0.11)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
  }

  @ViewBuilder
  private var artwork: some View {
    if let data = entry.artworkData, let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
    } else {
      ZStack {
        LinearGradient(
          colors: [Color(red: 0.46, green: 0.44, blue: 1), Color(red: 0.25, green: 0.22, blue: 0.62)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        Image(systemName: "dot.radiowaves.left.and.right")
          .font(.system(size: 27, weight: .semibold))
          .foregroundStyle(.white)
      }
    }
  }
}

struct FrekioWidget: Widget {
  let kind = "FrekioWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FrekioProvider()) { entry in
      FrekioWidgetView(entry: entry)
    }
    .configurationDisplayName("Frekio")
    .description("See and control the current Internet radio station.")
    .supportedFamilies([.systemMedium])
  }
}

@main
struct FrekioWidgetBundle: WidgetBundle {
  var body: some Widget {
    FrekioWidget()
  }
}
