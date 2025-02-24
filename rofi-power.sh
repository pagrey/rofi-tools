#!/usr/bin/env bash

set -e

I3EXIT="Logout"
REBOOT="Reboot"
POWEROFF="Poweroff"
CANCEL="Cancel"
YES="Yes"
ICON_PATH="~/.config/rofi/icons/"
ICON_LOGOUT="logout_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_REBOOT="refresh_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_POWER="power_settings_new_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_CHECK="check_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_CLOSE="close_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"

if [[ -n $ROFI_DATA ]]; then
	if [[ "$1" = "$YES" ]]; then 
		loginctl terminate-session ${XDG_SESSION_ID-}
		exit 0
	else
		exit 0
#		unset ROFI_DATA
	fi
fi

if [ $# -gt 0 ]
then
        case "$1" in
                "$I3EXIT")
			coproc ( i3-msg exit  > /dev/null  2>&1 )
			exit 0
                        ;;
                "$REBOOT")
			echo -e "\0data\x1freboot"
			echo -e "\0no-custom\x1ftrue"
#			echo -e "\0urgent\x1f0"
			echo -e "\0prompt\x1fconfirmation"
			echo -e "\0message\x1fAre you sure?"
			echo -e "$YES\0icon\x1f$ICON_PATH$ICON_CHECK"
			echo -e "$CANCEL\0icon\x1f$ICON_PATH$ICON_CLOSE"
			exit 0
                        ;;
                "$POWEROFF")
			echo -e "\0data\x1fpoweroff"
			echo -e "\0no-custom\x1ftrue"
#			echo -e "\0urgent\x1f0"
			echo -e "\0prompt\x1fconfirmation"
			echo -e "\0message\x1fAre you sure?"
			echo -e "$YES\0icon\x1f$ICON_PATH$ICON_CHECK"
			echo -e "$CANCEL\0icon\x1f$ICON_PATH$ICON_CLOSE"
			exit 0
                        ;;
		"$CANCEL")
			echo -e "\0message\x1f"
			;;
                *)
			exit 0
                        ;;
        esac
fi

echo -e "\0no-custom\x1ftrue"
echo -e "\0prompt\x1fpower"
echo -e "\0markup-rows\x1ftrue"
echo -e "$I3EXIT\0icon\x1f$ICON_PATH$ICON_LOGOUT"
echo -e "$REBOOT\0icon\x1f$ICON_PATH$ICON_REBOOT"
echo -e "$POWEROFF\0icon\x1f$ICON_PATH$ICON_POWER"
