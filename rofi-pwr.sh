#!/usr/bin/env bash

I3EXIT="Exit i3"
REBOOT="Reboot"
POWEROFF="Poweroff"
CANCEL="Cancel"
YES="Yes"

if [[ -n $ROFI_DATA ]]; then
	if [[ "$1" = "$YES" ]]; then 
		coproc ( $ROFI_DATA  > /dev/null  2>&1 )
	fi
	exit 0
fi


if [ $# -gt 0 ]
then
        case "$1" in
                "$I3EXIT")
			coproc ( i3-msg exit  > /dev/null  2>&1 )
			exit 0
                        ;;
                "$REBOOT")
			echo -e "\0data\x1freboot\n"
			echo -e "\0no-custom\x1ftrue\n"
			echo -en "\0urgent\x1f0\n"
			echo -en "\0prompt\x1fconfirmation\n"
			echo -en "\0message\x1fAre you sure?\n"
			echo -en "$YES\n"
			echo -en "$CANCEL\n"
			exit 0
                        ;;
                "$POWEROFF")
			echo -e "\0data\x1fpoweroff\n"
			echo -e "\0no-custom\x1ftrue\n"
			echo -en "\0urgent\x1f0\n"
			echo -en "\0prompt\x1fconfirmation\n"
			echo -en "\0message\x1fAre you sure?\n"
			echo -en "$YES\n"
			echo -en "$CANCEL\n"
			exit 0
                        ;;
                *)
			exit 0
                        ;;
        esac
fi

echo -e "\0no-custom\x1ftrue\n"
echo -en "\0prompt\x1fpower\n"
echo -en "\0markup-rows\x1ftrue\n"

echo -en "$I3EXIT\n"
echo -en "$REBOOT\n"
echo -en "$POWEROFF\n"

