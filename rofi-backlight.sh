#!/usr/bin/env bash
set -eu

INCREASE="Increase"
DECREASE="Decrease"
MAXIMUM="Maximum"
DEVICE=$(ls /sys/class/backlight)

if [[ -z $DEVICE ]]; then
	echo "backlight device not found!"
	exit 0
fi

if ! command -v backlight 2>&1 >/dev/null; then
    echo "backlight not found!"
    exit 0
fi

if [[ $# -gt 0 ]]; then
	if [[ $1 =~ ^[0-9]+$ ]]; then
	    backlight $1 > /dev/null 2>&1
	else
		case "$1" in
			"$INCREASE")
				backlight up > /dev/null 2>&1
				;;
			"$DECREASE")
				backlight down > /dev/null 2>&1
				;;
			"$MAXIMUM")
				backlight 100 > /dev/null 2>&1
				;;
		esac
	fi
fi

currentlevel=$(< /sys/class/backlight/$DEVICE/brightness)
maxlevel=$(< /sys/class/backlight/$DEVICE/max_brightness)
percent=$(($currentlevel * 101 / $maxlevel))
if [[ $percent -gt 100 ]]; then
	percent=100
fi

echo -e "\0prompt\x1fbacklight"
echo -e "\0markup-rows\x1ftrue"
echo -e "\0keep-selection\x1ftrue"
echo -e "\0message\x1f<b>Current level:</b> $percent%"
echo -e "$INCREASE\n$DECREASE\n$MAXIMUM"

