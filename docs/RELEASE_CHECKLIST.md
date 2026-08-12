# Release checklist

## Build quality
- [ ] Use current Flutter stable.
- [ ] `flutter pub get`
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter analyze` returns zero issues.
- [ ] `flutter test` passes.
- [ ] Debug and release builds run on physical Android and iPhone devices.
- [ ] Verify cold start, resume, process recreation, screen-off playback and network changes.
- [ ] Verify at least 20 Turkish stations across MP3/AAC/HLS where available.
- [ ] Verify dead stream, redirect, buffering, airplane mode and temporary network loss.
- [ ] Verify ICY metadata on stations that expose song/program titles.
- [ ] Verify bounded reconnect stops after three failed attempts and cancels on pause/stop.

## Accessibility/UI
- [ ] Dynamic text at large accessibility sizes.
- [ ] TalkBack and VoiceOver labels.
- [ ] Touch targets and contrast.
- [ ] Light/dark mode.
- [ ] Android edge-to-edge and iOS safe areas.
- [ ] Small and large phones.
- [ ] Tablet/iPad NavigationRail layout at 840+ logical pixels.
- [ ] Keyboard/focus traversal on large-screen layout.

## Android
- [ ] Final adaptive/monochrome launcher icon.
- [ ] Real release keystore configured; never publish with debug signing.
- [ ] App Bundle (`.aab`) release build.
- [ ] Background media notification and lock-screen controls.
- [ ] Android 13+ first-play media-player permission, allow/deny and system-settings recovery.
- [ ] Play-installed build: native review and flexible in-app update flows.
- [ ] Android home-screen widget play/pause/stop and process-restart restore.
- [ ] Bluetooth/headset media buttons.
- [ ] Android Auto Desktop Head Unit test.
- [ ] Physical Android Auto head unit/vehicle test if claiming compatibility.
- [ ] Play Console `mediaPlayback` foreground-service declaration and reviewer video.
- [ ] Complete Data Safety after reviewing actual third-party network behavior.

## iOS
- [ ] Set production bundle ID/signing team.
- [ ] Final AppIcon assets.
- [ ] Background audio on physical iPhone.
- [ ] Control Center / lock screen / Bluetooth.
- [ ] Verify iOS requests no notification permission for Now Playing.
- [ ] Production build: StoreKit review quota behavior and App Store version check.
- [ ] Runner and widget versions both match `pubspec.yaml`.
- [ ] Enable App Group `group.com.alpwarestudio.frekio` for Runner and FrekioWidgetExtension.
- [ ] iOS 17+ widget play/pause/stop on a physical device.
- [ ] Request/enable Apple CarPlay audio entitlement if full CarPlay browsing is part of the release.
- [ ] CarPlay Simulator test after entitlement/configuration.
- [ ] CarPlay cold launch without opening the phone UI first.
- [ ] Physical CarPlay head unit/vehicle test if claiming compatibility.
- [ ] Complete App Privacy after reviewing third-party retention.

## Content/legal
- [ ] Publish privacy policy at a public HTTPS URL.
- [ ] Final product-name/trademark clearance for “Frekio”.
- [ ] Confirm store screenshots do not imply ownership of broadcaster brands.
- [ ] Confirm broadcaster logo/name handling is appropriate.
- [ ] Include open-source notices/licenses where required.

## Store assets
- [ ] App icon.
- [ ] Android feature graphic.
- [ ] Phone screenshots in TR and EN.
- [ ] App Store screenshots for required device classes.
- [ ] Support URL.
- [ ] Privacy policy URL.
- [ ] Store descriptions reviewed in both languages.
