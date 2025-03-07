#!/usr/bin/env bash

UP="Increase"
DOWN="Decrease"
MAX="Maximum"
MUTE="Mute"
MESSAGE="Output volume:"
TAB=" "

if ! command -v amixer 2>&1 >/dev/null; then
    echo "No audio control (amixer) found!"
    exit 0
fi

if [[ $# -gt 0 ]]; then
	if [[ $1 =~ ^[0-9]+$ ]]; then
		amixer -Mq set Master $1% > /dev/null 2>&1
	else
		case "$1" in
			"$UP")
				amixer -Mq set Master 5%+ > /dev/null 2>&1
				;;
			"$DOWN")
				amixer -Mq set Master 5%- > /dev/null 2>&1
				;;
			"$MAX")
				amixer -Mq set Master 100% > /dev/null 2>&1
				;;
			"$MUTE")
				amixer -Mq set Master toggle > /dev/null 2>&1
				;;
		esac
	fi
fi

volume=$(amixer -M get Master | sed -e '1,4d' -e 's/^.*[0-9\] \[//' -e 's/\].*//')
mutedisabled=$(amixer get Master | sed -e '1,4d' -e 's/^.*\[//' -e 's/\]//')

echo -e "\0message\x1f<b>$MESSAGE</b> $volume"
echo -e "\0prompt\x1fvolume"
echo -e "\0keep-selection\x1ftrue"
	
echo -e "$UP\0message\x1f$TAB$UP"
echo -e "$DOWN\0message\x1f$TAB$DOWN"
echo -e "$MAX\0message\x1f$TAB$MAX"
let COUNTER+=3
if [[ $mutedisabled = "off" ]]; then
	echo -e "\0urgent\x1f$COUNTER"
	echo  -e "$MUTE\0message\x1f$TAB$MUTE"
else
	echo  -e "$MUTE\0message\x1f$TAB$MESSAGE"
fi
