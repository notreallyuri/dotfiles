#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +'%Y-%m-%d-%H%M%S').png"

copy_and_notify() {
  if [ -f "$FILE" ]; then
    wl-copy <"$FILE"
    notify-send -i "$FILE" "Screenshot Captured" "Saved to $FILE" -a "Screenshot Tool"
  fi
}

case "$1" in
full)
  grim "$FILE"
  copy_and_notify
  ;;

region)
  GEOM=$(slurp) || exit 1
  grim -g "$GEOM" "$FILE"
  copy_and_notify
  ;;
window)
  GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

  if [ "$GEOM" == "0,0 0x0" ]; then
    notify-send "Screenshot" "No active window found"
    exit 1
  fi

  grim -g "$GEOM" "$FILE"
  copy_and_notify
  ;;

*)
  notify-send "Screenshot" "Invalid: $1"
  exit 1
  ;;
esac

exit 0
