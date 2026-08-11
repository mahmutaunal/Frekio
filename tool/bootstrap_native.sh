#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or is not on PATH." >&2
  exit 1
fi

flutter channel stable
flutter create . --platforms=android,ios --org com.alpwarestudio
flutter pub get
dart format .
flutter analyze
flutter test

cat <<'EOF'

Bootstrap completed.
Next:
  flutter run

Before store release, read:
  docs/RELEASE_CHECKLIST.md
  docs/GOOGLE_PLAY_DECLARATIONS.md
  docs/APP_STORE_DECLARATIONS.md
EOF
