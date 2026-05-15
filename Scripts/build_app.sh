#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="TextSniperLocal"
APP_DIR="$ROOT_DIR/build/${APP_NAME}.app"
SWIFT_TRIPLE="arm64-apple-macosx13.0"

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Apple Silicon Mac에서만 빌드할 수 있습니다." >&2
  exit 1
fi

cd "$ROOT_DIR"

swift build -c release --triple "$SWIFT_TRIPLE"
BIN_DIR="$(swift build -c release --triple "$SWIFT_TRIPLE" --show-bin-path)"
"$ROOT_DIR/Scripts/make_icon.sh" >/dev/null

if [[ "$(lipo -archs "$BIN_DIR/$APP_NAME")" != "arm64" ]]; then
  echo "arm64 단일 바이너리 생성에 실패했습니다." >&2
  exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BIN_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/Packaging/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT_DIR/Packaging/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"

find "$APP_DIR" -depth -exec xattr -c {} \; 2>/dev/null || true
codesign --force --deep --sign - "$APP_DIR" >/dev/null
find "$APP_DIR" -depth -exec xattr -c {} \; 2>/dev/null || true
codesign --verify --deep "$APP_DIR"

echo "$APP_DIR"
