# Native setup checklist

## Android

Required manifest permissions:
- INTERNET
- WAKE_LOCK
- FOREGROUND_SERVICE
- FOREGROUND_SERVICE_MEDIA_PLAYBACK

The audio service must be exported with `android.media.browse.MediaBrowserService` intent filter and `foregroundServiceType="mediaPlayback"`.

Do not request battery-optimization exemption. A well-behaved radio app should use the platform foreground media service rather than asking the user to disable battery optimization.

For release signing, copy `android/key.properties.example` to `android/key.properties`, point it to the upload keystore, and keep both files containing secrets out of Git. Release builds never fall back to the debug key.

## iOS

Enable:
- Background Modes → Audio, AirPlay, and Picture in Picture
- App Group `group.com.alpwarestudio.frekio` for Runner and FrekioWidgetExtension
- Network access is inherent; no broad privacy permission is required for ordinary HTTPS Internet radio.

For App Store CarPlay distribution:
1. Use an Apple Developer account.
2. Request/enable the applicable CarPlay audio capability/entitlement if required for your chosen CarPlay presentation.
3. Test with the CarPlay Simulator and at least one physical vehicle/head unit before claiming full compatibility.
4. Keep driver interactions shallow and use Apple-provided templates/system media controls.

The checked-in `Runner.entitlements` contains only the App Group. After Apple grants CarPlay audio access, add the granted entitlement to the signed target/profile; never self-sign an entitlement that is not enabled for the App ID.

The Flutter layer does not request camera, microphone, contacts, location, Photos or advertising tracking permissions.

## Store readiness

Before publishing:
- Replace launcher icons and store artwork with final brand assets.
- Add store listing screenshots and descriptions.
- Confirm every third-party station/logo use is lawful.
- Publish the included privacy policy on a public URL.
- Complete Google Play Data Safety and Apple App Privacy forms accurately.
