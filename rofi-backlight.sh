#!/usr/bin/env bash

set -e
set -u
DEVICE=$(ls /sys/class/backlight)

if [[ -z $DEVICE ]]; then
	echo "No backlight found!"
	exit 0
fi

options=(Decrease Increase Maximum)

declare -A actions
actions[Decrease]="sudo brightness down"
actions[Increase]="sudo brightness up"
actions[Maximum]="sudo brightness 100"

if [ $# -gt 0 ]
then
    for entry in "${options[@]}"
    do
        if [ "$entry" = "$1" ]
        then
            ${actions[$entry]} > /dev/null 2>&1
        fi
    done
    if [[ $1 =~ ^[0-9]+$ ]]; then
#    if [ "$1" -eq "$1" ] 2> /dev/null; then
	    sudo brightness $1 > /dev/null 2>&1
    fi
fi
for entry in "${options[@]}"
do
    echo "$entry"
done

currentlevel=$(< /sys/class/backlight/$DEVICE/brightness)
maxlevel=$(< /sys/class/backlight/$DEVICE/max_brightness)
percent=$(($currentlevel * 101 / $maxlevel))
if [ $percent -gt 100 ]; then
	percent=100
fi

echo -en "\0prompt\x1fbacklight\n"
echo -en "\0markup-rows\x1ftrue\n"
echo -en "\0message\x1f<b>Current level:</b> $percent%\n"
