# Architecture

Frekio intentionally stays compact.

- `data/`: Radio Browser HTTP API and local preferences.
- `domain/`: immutable station model.
- `services/`: background audio and system media controls.
- `app_state.dart`: application state coordinator.
- `ui/`: responsive/adaptive presentation.

## Battery strategy

1. One audio player instance only.
2. No periodic background location, analytics, sync or polling.
3. Station catalogue is cached locally with a six-hour TTL.
4. Searches are user-driven and debounced in the UI.
5. The audio service remains foreground only while media playback requires it.
6. Sleep timer uses one in-process timer and is cancelled when not needed.
7. Station artwork is loaded directly by system/player surfaces; no prefetch crawler.
8. Failed streams are not retried in a tight loop.
9. App pauses on audio interruptions according to the platform audio session.

## Android Auto

`audio_service` publishes the media session and browser service expected by Android Auto. The handler exposes Favorites, Recent and Popular Turkey nodes through `getChildren`, supports voice queries through `playFromSearch`, and starts stations through `playFromMediaId`.

## CarPlay

The native `CarPlaySceneDelegate` exposes Favorites and Recent as Apple-provided list/tab templates and forwards selections to the same Flutter audio handler. A single eagerly started Flutter engine makes this work even when CarPlay launches before the phone UI. `audio_service` continues to own Now Playing and remote commands. Signed distribution still requires Apple’s CarPlay audio entitlement and review approval. See `docs/NATIVE_SETUP.md`.

## Home-screen widgets

Android uses a zero-polling `AppWidgetProvider`; media buttons are forwarded to the active media session, station artwork is downloaded only when its URL changes and cached at a bounded size, and the last station is restored after process recreation. iOS 17+ uses WidgetKit and `AudioPlaybackIntent`, with state shared locally through `group.com.alpwarestudio.frekio`. Widget updates are event-driven, not periodic.

System playback surfaces remain platform-owned. Android receives a valid
`MediaStyle` notification and `MediaSession` token so Pixel, One UI and other
System UI implementations can render their current media card. iOS receives
the matching MediaItem metadata and remote commands for Now Playing surfaces.


## Live metadata and resilience

Frekio listens to `just_audio` ICY metadata when a station exposes it. The station remains the primary media title while the live programme/song title is published as secondary system metadata. No separate metadata polling is performed.

Transient player failures use a deliberately bounded reconnect policy (2s, 5s, 10s; maximum three attempts). User pause/stop cancels recovery immediately. This avoids an infinite retry loop, excess radio/network use, and unnecessary battery drain.

## Adaptive layout

Phone-sized surfaces use a Material 3 `NavigationBar`. At 840 logical pixels and above, the same destinations move to a `NavigationRail`; content is capped at a readable maximum width. This follows Flutter's adaptive guidance instead of stretching phone layouts across tablets/iPads.
