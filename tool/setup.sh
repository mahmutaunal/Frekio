#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install the current stable Flutter release and ensure 'flutter' is on PATH." >&2
  exit 1
fi

# Preserve product-owned files because `flutter create .` may refresh template files.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
for item in pubspec.yaml analysis_options.yaml README.md LICENSE PRIVACY.md SECURITY.md CONTRIBUTING.md CHANGELOG.md lib test docs assets .github tool; do
if [ -e "$item" ]; then cp -R "$item" "$TMP_DIR/"; fi
done
if [ -d ios/FrekioWidget ]; then cp -R ios/FrekioWidget "$TMP_DIR/"; fi

# Generate complete native Flutter scaffolding (Gradle wrapper, Xcode project,
# storyboards and platform files) for the locally installed stable SDK.
flutter create . \
  --platforms=android,ios \
  --org com.alpwarestudio \
  --project-name frekio_radio

# Restore product-owned source/docs/tooling after template generation.
for item in pubspec.yaml analysis_options.yaml README.md LICENSE PRIVACY.md SECURITY.md CONTRIBUTING.md CHANGELOG.md lib test docs assets .github tool; do
  if [ -e "$TMP_DIR/$item" ]; then
    rm -rf "$item"
    cp -R "$TMP_DIR/$item" "$item"
  fi
done

# Restore Frekio-specific native configuration after Flutter template generation.
if [ -d tool/platform_overrides ]; then
  cp -R tool/platform_overrides/android/. android/
  cp -R tool/platform_overrides/ios/. ios/
fi
if [ -d "$TMP_DIR/FrekioWidget" ]; then
  mkdir -p ios/FrekioWidget
  cp -R "$TMP_DIR/FrekioWidget/." ios/FrekioWidget/
fi

# Register Frekio-owned Swift sources in the generated Xcode project.
python3 tool/configure_ios_project.py
tool/configure_ios_widget.sh

# Install final iOS icon catalog.
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset
cp tool/generated_ios_appicon/* ios/Runner/Assets.xcassets/AppIcon.appiconset/

flutter pub get
dart format .
flutter analyze
flutter test

echo
echo "Frekio setup and validation completed successfully."
echo "Run: flutter run"
echo "Release checklist: docs/RELEASE_CHECKLIST.md"
