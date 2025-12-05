#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +'%Y-%m-%d-%H%M%S').png"

copy_to_clipboard() {
	wl-copy <"$FILE"
}

case "$1" in
full)
	grim "$FILE"
	copy_to_clipboard
	notify-send "Screenshot" "Saved to $FILE"
	;;

region)
	grim -g "$(slurp)" "$FILE"
	copy_to_clipboard
	notify-send "Screenshot" "Saved to $FILE"
	;;
window)
	WX=$(hyprctl activewindow -j | jq -r '.at[0]')
	WY=$(hyprctl activewindow -j | jq -r '.at[1]')
	WW=$(hyprctl activewindow -j | jq -r '.size[0]')
	WH=$(hyprctl activewindow -j | jq -r '.size[1]')

	MON=$(hyprctl activewindow -j | jq -r '.monitor')

	MX=$(hyprctl monitors -j | jq -r ".[$MON].x")
	MY=$(hyprctl monitors -j | jq -r ".[$MON].y")

	GX=$((WX + MX))
	GY=$((WY + MY))

	GEOM="${GX},${GY} ${WW}x${WH}"

	grim -g "$GEOM" "$FILE"
	copy_to_clipboard
	notify-send "Screenshot" "Saved to $FILE"
	;;

*)
	notify-send "Screenshot" "Invalid: $1"
	exit 1
	;;
esac

exit 0
