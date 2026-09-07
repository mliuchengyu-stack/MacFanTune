#!/bin/zsh
set -e

ROOT="${0:A:h}"
APP="$ROOT/dist/FanTune.app"
OUTPUT="${1:-$ROOT/dist/FanTune-1.0.0-Universal.dmg}"
OUTPUT="${OUTPUT:A}"

if [[ ! -d "$APP" ]]; then
  "$ROOT/build-app.sh"
fi

mkdir -p "${OUTPUT:h}"
rm -f "$OUTPUT"
cd "$ROOT"
magick -background white Resources/dmg-background.svg -alpha remove -alpha off -depth 8 Resources/dmg-background.png
npm exec --yes --package=@jmole/appdmg -- appdmg Resources/appdmg.json "$OUTPUT"
[[ -f "$OUTPUT" ]] || { echo "DMG 生成失败：未找到输出文件" >&2; exit 1; }
hdiutil verify "$OUTPUT"
echo "已生成：$OUTPUT"
