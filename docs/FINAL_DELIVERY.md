# Frekio — Final delivery notes

This ZIP is the final source delivery for the requested Flutter Internet radio application.

## Product scope delivered

- Android + iOS Flutter codebase.
- Turkey-first dynamic station discovery through Radio Browser; no hardcoded station catalogue.
- Worldwide station search with optional Turkey-only filtering.
- Favorites, recents, six-hour catalogue cache and sleep timer.
- Background audio with system/lock-screen/Bluetooth controls.
- Android Auto browsable media tree (Favorites, Recent, Turkey) plus voice search.
- Native CarPlay Favorites/Recent templates connected to the shared audio handler.
- Android home-screen playback widget and iOS 17+ interactive WidgetKit controls.
- Live ICY title metadata where the broadcaster supplies it.
- Controlled reconnect (2s / 5s / 10s; no tight retry loop).
- Material 3 phone UI plus NavigationRail on tablets/iPad-sized layouts.
- Turkish + English interface, system/light/dark appearance.
- Edge-to-edge system UI.
- No ads, account, Firebase, analytics, tracking SDK, paid backend or paid API.
- MIT open-source license, privacy policy, security/contribution docs, CI workflow, store-listing drafts and submission notes.
- Final launcher icon assets for Android/iOS.

## One-command project completion

The source delivery intentionally lets the locally installed stable Flutter SDK generate Gradle/Xcode scaffolding that exactly matches that SDK. This avoids shipping stale generated project boilerplate.

Run once from the repository root:

```bash
./tool/setup.sh
```

The script generates the native scaffolding, restores Frekio's native media/Auto/background configuration, installs the icon catalog, fetches packages, formats, analyzes and runs tests. It stops on the first failure.

## External platform gates that source code cannot remove

- Android Auto compatibility still has to be validated with Google's Desktop Head Unit and ideally real vehicle hardware before making an absolute compatibility claim.
- CarPlay templates are implemented, but distribution requires Apple to grant the CarPlay audio entitlement/capability, a matching signed profile, and simulator/vehicle validation.
- The iOS widget uses App Group `group.com.alpwarestudio.frekio`; enable that group for both the app and widget extension in the Apple Developer portal before device signing.
- Google Play / App Store publication requires the relevant developer account, signing identity and store review. These are platform requirements, not Frekio runtime-service costs.

## Release identity

- App: Frekio
- Package / Android application ID: `com.alpwarestudio.frekio`
- Source version: `1.3.0+4`
- License: MIT
