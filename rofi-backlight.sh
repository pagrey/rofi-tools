#!/usr/bin/env bash

set -e
set -u
INCREASE="Increase"
DECREASE="Decrease"
MAXIMUM="Maximum"
DEVICE=$(ls /sys/class/backlight)
ICON_PATH="~/.config/rofi/icons/"
ICON_UP="keyboard_arrow_up_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_DOWN="keyboard_arrow_down_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_MAX="brightness_7_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"

if [[ -z $DEVICE ]]; then
	echo "No backlight found!"
	exit 0
fi

if [ $# -gt 0 ]
then
	if [[ $1 =~ ^[0-9]+$ ]]; then
	    coproc ( backlight $1 > /dev/null 2>&1 )
	else
		case "$1" in
			"$INCREASE")
				coproc ( backlight up > /dev/null 2>&1 )
				;;
			"$DECREASE")
				coproc ( backlight down > /dev/null 2>&1 )
				;;
			"$MAXIMUM")
				coproc ( backlight 100 > /dev/null 2>&1 )
				;;
		esac
	fi
fi

currentlevel=$(< /sys/class/backlight/$DEVICE/brightness)
maxlevel=$(< /sys/class/backlight/$DEVICE/max_brightness)
percent=$(($currentlevel * 101 / $maxlevel))
if [ $percent -gt 100 ]; then
	percent=100
fi

echo -e "\0prompt\x1fbacklight"
echo -e "\0markup-rows\x1ftrue"
echo -e "\0keep-selection\x1ftrue"
echo -e "\0message\x1f<b>Current level:</b> $percent%"

echo -e "$INCREASE\0icon\x1f$ICON_PATH$ICON_UP"
echo -e "$DECREASE\0icon\x1f$ICON_PATH$ICON_DOWN"
echo -e "$MAXIMUM\0icon\x1f$ICON_PATH$ICON_MAX"
