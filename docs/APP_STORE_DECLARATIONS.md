# App Store declaration notes

These are submission working notes; verify the live App Store Connect questions when publishing.

## Privacy

Frekio contains no developer analytics, ad SDK, login, tracking identifier, location, contacts, camera or microphone collection.

Network traffic is still sent to third-party services:
- Radio Browser for station discovery and a station-click event.
- The selected broadcaster for the audio stream.
- Apple's iTunes Search/App Store service for version availability.
- StoreKit when the system offers a native rating prompt.

Apple's App Privacy definition focuses on data transmitted off-device and retained by the developer or third-party partners beyond servicing the request. Whether a particular request must be disclosed depends on the third party's retention and use. Confirm Radio Browser/broadcaster practices before selecting “Data Not Collected.”

## Background audio

`UIBackgroundModes` includes `audio` because continuing a user-started radio stream with the display off is core functionality.

## Notifications, ratings and updates

Frekio does not request user-notification authorization for media playback. iOS
Now Playing uses the active audio session, Lock Screen and Control Center. The
StoreKit rating prompt is requested sparingly after meaningful use; StoreKit
retains full control over whether it is displayed. Version checks compare the
installed bundle version with Apple's public store metadata.

## CarPlay

Native Favorites/Recent CarPlay browsing is implemented. Distribution requires Apple's CarPlay audio entitlement/capability and platform validation. Do not add an entitlement value that Apple has not granted to the App ID.

## Widget and App Group

The iOS 17+ WidgetKit extension uses App Group `group.com.alpwarestudio.frekio` only to display and control current playback. Enable the group for both bundle IDs before signing:

- `com.alpwarestudio.frekio`
- `com.alpwarestudio.frekio.widget`
