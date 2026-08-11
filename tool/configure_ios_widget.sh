#!/usr/bin/env bash
set -euo pipefail

if ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
  ruby tool/configure_ios_widget.rb
  exit 0
fi

if command -v pod >/dev/null 2>&1; then
  POD_WRAPPER="$(command -v pod)"
  POD_GEM_HOME="$(sed -n 's/^GEM_HOME="\([^"]*\)".*/\1/p' "$POD_WRAPPER" | head -1)"
  if [ -n "$POD_GEM_HOME" ] && GEM_HOME="$POD_GEM_HOME" ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
    GEM_HOME="$POD_GEM_HOME" ruby tool/configure_ios_widget.rb
    exit 0
  fi
fi

echo "The Ruby xcodeproj gem is required to configure the iOS widget target." >&2
echo "Install xcodeproj, then rerun this setup script." >&2
exit 1
