#!/usr/bin/env bash
set -e

I3EXIT="Exit i3"
LOGOUT="Logout"
REBOOT="Reboot"
POWEROFF="Poweroff"
CANCEL="Cancel"
YES="Yes"

if [[ -n $ROFI_DATA ]]; then
	if [[ "$1" = "$YES" ]]; then 
		case "$ROFI_DATA" in
			"$REBOOT")
				reboot
				exit 0
				;;
			"$POWEROFF")
				poweroff
				exit 0
				;;
			*)
				exit 0
				;;
		esac
	else
		unset ROFI_DATA
	fi
fi

if [[ $# -gt 0 ]]; then
        case "$1" in
		"$LOGOUT")
			coproc ( loginctl kill-session "${XDG_SESSION_ID-}"  > /dev/null  2>&1 )
			exit 0
			;;
                "$I3EXIT")
			coproc ( i3-msg exit  > /dev/null  2>&1 )
			exit 0
                        ;;
                "$REBOOT")
			echo -e "\0data\x1f$REBOOT"
			echo -e "\0no-custom\x1ftrue"
			echo -e "\0prompt\x1fconfirmation"
			echo -e "\0message\x1fAre you sure?"
			echo -e "$YES"
			echo -e "$CANCEL"
			exit 0
                        ;;
                "$POWEROFF")
			echo -e "\0data\x1f$POWEROFF"
			echo -e "\0no-custom\x1ftrue"
			echo -e "\0prompt\x1fconfirmation"
			echo -e "\0message\x1fAre you sure?"
			echo -e "$YES"
			echo -e "$CANCEL"
			exit 0
                        ;;
                *)
			exit 0
                        ;;
        esac
fi

echo -e "\0no-custom\x1ftrue"
echo -e "\0prompt\x1fpower"
echo -e "\0markup-rows\x1ftrue"
echo -e "$I3EXIT"
echo -e "$LOGOUT"
echo -e "$REBOOT"
echo -e "$POWEROFF"
