#!/bin/zsh
set -e
ROOT="${0:A:h}"
cd "$ROOT"
APP="$ROOT/dist/FanTune.app"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"
mkdir -p "$ROOT/.cache/clang"
ARCHS=(-arch arm64 -arch x86_64)
CLANG_MODULE_CACHE_PATH="$ROOT/.cache/clang" clang "${ARCHS[@]}" -fobjc-arc -O2 -framework Cocoa -framework QuartzCore "$ROOT/Native/main.m" -o "$APP/Contents/MacOS/FanTune"
CLANG_MODULE_CACHE_PATH="$ROOT/.cache/clang" clang "${ARCHS[@]}" -O2 -framework IOKit -framework CoreFoundation "$ROOT/Native/smc_helper.c" -o "$APP/Contents/Resources/fantune-smc"
cp "$ROOT/THIRD_PARTY_NOTICES.txt" "$APP/Contents/Resources/THIRD_PARTY_NOTICES.txt"
cp "$ROOT/Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
chmod +x "$APP/Contents/MacOS/FanTune"
chmod +x "$APP/Contents/Resources/fantune-smc"
codesign --force --deep --sign - "$APP"
echo "已生成：$APP"
