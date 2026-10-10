#!/bin/sh
# Installs or updates Bridge on an Apple-silicon Mac and opens it:
#
#   curl -fsSL https://raw.githubusercontent.com/jgeschwendt/bifrost-releases/main/install.sh | sh
#
# The app bundle comes from this repository's latest release. Bridge then
# installs its own Erlang runtime and app layer and keeps all three current.
# BRIDGE_INSTALL_DIR overrides /Applications.
set -eu

repo=jgeschwendt/bifrost-releases
dest=${BRIDGE_INSTALL_DIR:-/Applications}
app="$dest/Bridge.app"

[ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ] ||
  { echo "Bridge runs on Apple-silicon macOS only" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading the latest Bridge…"
curl -fsSL --proto '=https' -o "$tmp/Bridge.app.tar.gz" \
  "https://github.com/$repo/releases/latest/download/Bridge.app.tar.gz"
tar -xzf "$tmp/Bridge.app.tar.gz" -C "$tmp"
[ -d "$tmp/Bridge.app" ] || { echo "the release did not contain Bridge.app" >&2; exit 1; }

if [ -d "$app" ]; then
  echo "replacing $app"
  osascript -e 'tell application "Bridge" to quit' >/dev/null 2>&1 || true
  i=0
  while pgrep -qx bifrost && [ $i -lt 20 ]; do sleep 0.5; i=$((i + 1)); done
  pgrep -qx bifrost && { echo "Bridge is still running: quit it from the menu bar and rerun" >&2; exit 1; }
  rm -rf "$app"
fi
mkdir -p "$dest"
mv "$tmp/Bridge.app" "$app"
echo "installed $app"
open -a "$app"
