# Google Play declaration notes

These are submission working notes, not a substitute for checking the final Play Console wording on submission day.

## Permissions in the app

- `INTERNET`: fetch station directory and play broadcaster streams.
- `WAKE_LOCK`: required by the background audio stack while playback is active.
- `FOREGROUND_SERVICE`: background user-visible audio playback.
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Android 14+ media-playback FGS type.
- `POST_NOTIFICATIONS`: Android 13+ runtime permission for user-visible playback
  artwork and controls. It is requested only in direct response to the first
  playback action, and playback remains usable when permission is declined.

No location, contacts, camera, microphone, storage/media-library, advertising ID, SMS or phone permissions are requested.

## Foreground service declaration

Type: `mediaPlayback`

Suggested description:
“Frekio plays a radio stream explicitly selected by the user. Playback must continue while the screen is off or another app is in the foreground. The active media notification shows playback controls and lets the user stop playback.”

Reviewer video should show:
1. Open Frekio.
2. Select a radio station.
3. Return to Home/lock screen.
4. Show that the stream continues and the media notification/lock-screen controls are visible.
5. Stop playback from the system control.

## Data Safety — conservative review

Do **not** blindly select “No data collected” without reviewing the final network behavior.

The app sends:
- Radio Browser API requests to retrieve station metadata.
- A station-selection click request to Radio Browser when the user selects a station.
- Direct network requests to the broadcaster stream chosen by the user.
- Google Play In-App Review and In-App Update requests when rating or update
  functionality is invoked. These flows are handled by Google Play.

The app itself has no account, analytics, advertising, tracking SDK or developer backend. Favorites/recent history/settings stay on device.

Google defines collection broadly as transmitting user data off-device, including to third parties. On submission day, inspect whether Radio Browser/broadcaster request logs create a declarable data type under the then-current form. If click reporting is considered “App interactions,” declare it conservatively rather than understating collection.
