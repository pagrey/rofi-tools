#!/usr/bin/env bash

DISCONNECT="Disconnect"
stations=(Cinemix VeniceClassical RadioDismuke 1920sRadioNetwork 1940sRadio 1940sUKRadio BigBlueSwing ElectroLounge LoungeRadio)
ICON_PATH="~/.config/rofi/icons/"
ICON_CLOSE="close_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_CAST="music_cast_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_RULE="horizontal_rule_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_OFF="music_off_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
PAD=" "

declare -A url
url[RadioDismuke]="http://stream1.early1900s.org:8080"
url[1920sRadioNetwork]="http://208.85.242.72:8398"
url[1940sRadio]="http://199.189.111.28:8012"
url[1940sUKRadio]="http://91.121.134.23:8100"
url[BigBlueSwing]="http://209.236.126.18:8002"
url[ElectroLounge]="https://electrolounge.stream.laut.fm/electrolounge?pl=pls&t302=2024-08-26_23-57-55&uuid=ba9e3f02-429f-4659-9ae5-acf6715fb367"
url[LoungeRadio]="http://nl1.streamhosting.ch:80"
url[VeniceClassical]="http://116.202.241.212:8010"
url[Cinemix]="http://51.81.46.118:1190"

nowplaying=$(ps hw -C ffplay -o args= | sed -e 's/^.*nodisp //')

if [ $# -gt 0 ]
then
        case "$1" in
                "$DISCONNECT")
			killall ffplay > /dev/null 2>&1
			unset nowplaying
			exit 0
                        ;;
                *)
			killall ffplay > /dev/null 2>&1
			coproc( ffplay -loglevel 8 -nodisp ${url[$1]} > /dev/null 2>&1 )
			nowplaying=${url[$1]}
			exit 0
                        ;;
        esac
fi
echo -e "\0markup-rows\x1ftrue"

if [[ -n $nowplaying ]]; then
    	echo -e "$DISCONNECT\0permanent\x1ftrue\x1ficon\x1f$ICON_PATH$ICON_OFF"
fi
	
COUNTER=1
for entry in "${stations[@]}"
do
    if [[ $nowplaying = ${url[$entry]} ]]
    then
	stationplaying=$entry
	echo -e "\0active\x1f$COUNTER"
        echo -e "$entry\0display\x1f$PAD$entry\x1fnonselectable\x1ftrue\x1ficon\x1f$ICON_PATH$ICON_CAST"
        echo -e "\0message\x1f<b>Current station:</b> $stationplaying"
    else
    	echo -e "$entry\0display\x1f$PAD$entry\x1ficon\x1f$ICON_PATH$ICON_RULE"
    fi
    let COUNTER++
done

echo -e "\0no-custom\x1ftrue"
echo -e "\0prompt\x1fradio"
