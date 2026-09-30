#!/bin/sh

LOCKSCREEN_MONITORS=(DP-2 eDP-1)
OUTPUT_FILENAME="$HOME/repos/dotfiles/.config/hypr/hyprlock.conf"

cat 'head.conf' > "$OUTPUT_FILENAME"

for MONITOR in "${LOCKSCREEN_MONITORS[@]}"; do
  sed 's/$main_monitor/'"$MONITOR/g" 'dynamic.conf' >> "$OUTPUT_FILENAME"
done

