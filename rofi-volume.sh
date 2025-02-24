#!/usr/bin/env bash

UP="Volume Up"
DOWN="Volume Down"
MAX="Volume Max"
MUTE="Volume Mute"
ICON_PATH="~/.config/rofi/icons/"
ICON_UP="volume_down_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_DOWN="volume_mute_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_MUTE="volume_off_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_MAX="volume_up_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"

if [ $# -gt 0 ]
then
	if [[ $1 =~ ^[0-9]+$ ]]; then
		coproc ( amixer -Mq set Master $1% > /dev/null 2>&1 )
	else
		case "$1" in
			"$UP")
				coproc ( amixer -Mq set Master 5%+ > /dev/null 2>&1 )
				;;
			"$DOWN")
				coproc ( amixer -Mq set Master 5%- > /dev/null 2>&1 )
				;;
			"$MAX")
				coproc ( amixer -Mq set Master 100% > /dev/null 2>&1 )
				;;
			"$MUTE")
				coproc ( amixer -Mq set Master toggle > /dev/null 2>&1 )
				;;
		esac
	fi
fi

volume=$(amixer -M get Master | sed -e '1,4d' -e 's/^.*[0-9\] \[//' -e 's/\].*//')
mutedisabled=$(amixer get Master | sed -e '1,4d' -e 's/^.*\[//' -e 's/\]//')

echo -e "\0message\x1f<b>Current volume:</b> $volume"
#echo -e "\0no-custom\x1ftrue"
echo -e "\0prompt\x1fvolume"
echo -e "\0keep-selection\x1ftrue"
	
echo -e "$UP\0icon\x1f$ICON_PATH$ICON_UP"
echo -e "$DOWN\0icon\x1f$ICON_PATH$ICON_DOWN"
echo  -e "$MAX\0icon\x1f$ICON_PATH$ICON_MAX"
let COUNTER+=3
if [[ $mutedisabled = "off" ]]; then
	echo -e "\0urgent\x1f$COUNTER"
	echo  -e "$MUTE\0icon\x1f$ICON_PATH$ICON_MUTE"
else
	echo  -e "$MUTE\0icon\x1f$ICON_PATH$ICON_MUTE"
fi
