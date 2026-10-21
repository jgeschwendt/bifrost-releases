#!/bin/sh
# Installs or updates Bifrost on an Apple-silicon Mac and opens it:
#
#   curl -fsSL https://raw.githubusercontent.com/jgeschwendt/bifrost-releases/main/install.sh | sh
#
# The app bundle comes from this repository's latest release. Bifrost then
# installs its own Erlang runtime and app layer and keeps all three current.
# BIFROST_INSTALL_DIR overrides /Applications.
set -eu

repo=jgeschwendt/bifrost-releases
dest=${BIFROST_INSTALL_DIR:-/Applications}
app="$dest/Bifrost.app"

[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] ||
  { echo "Bifrost runs on Apple-silicon macOS only" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading the latest Bifrost…"
curl -fsSL --proto '=https' -o "$tmp/Bifrost.app.tar.gz" \
  "https://github.com/$repo/releases/latest/download/Bifrost.app.tar.gz"
tar -xzf "$tmp/Bifrost.app.tar.gz" -C "$tmp"
[ -d "$tmp/Bifrost.app" ] || { echo "the release did not contain Bifrost.app" >&2; exit 1; }

if [ -d "$app" ]; then
  echo "replacing $app"
  osascript -e 'tell application "Bifrost" to quit' >/dev/null 2>&1 || true
  i=0
  while pgrep -qx bifrost && [ $i -lt 20 ]; do sleep 0.5; i=$((i + 1)); done
  pgrep -qx bifrost && { echo "Bifrost is still running: quit it from the menu bar and rerun" >&2; exit 1; }
  rm -rf "$app"
fi
mkdir -p "$dest"
mv "$tmp/Bifrost.app" "$app"
echo "installed $app"
open -a "$app"
