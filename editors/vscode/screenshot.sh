#!/usr/bin/env bash

set -euo pipefail

output="${1:-$HOME/Pictures/1am-vscode.png}"
capture="$(mktemp --suffix=.png)"
rounded="$(mktemp --suffix=.png)"
trap 'rm -f "$capture" "$rounded"' EXIT

sleep 3
geometry="$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
grim -g "$geometry" "$capture"

read -r width height <<< "$(magick identify -format '%w %h' "$capture")"
magick "$capture" -alpha set \
  \( -size "${width}x${height}" xc:none -fill white \
    -draw "roundrectangle 0,0 $((width - 1)),$((height - 1)) 6,6" \) \
  -compose DstIn -composite "$rounded"

mkdir -p "$(dirname "$output")"
magick \
  \( "$rounded" -background black -shadow 20x6+0+4 \) \
  "$rounded" -background none -layers merge +repage "$output"

printf 'Saved screenshot to %s\n' "$output"
