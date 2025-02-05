#!/usr/bin/env bash

DISCONNECT="Disconnect"
UP="Volume Up"
DOWN="Volume Down"
MAX="Volume Max"
MUTE="Volume Mute"
stations=(Cinemix VeniceClassical RadioDismuke 1920sRadioNetwork 1940sRadio 1940sUKRadio BigBlueSwing ElectroLounge LoungeRadio)

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
                "$UP")
			amixer -q set Master 5+ > /dev/null 2>&1
                        ;;
                "$DOWN")
			amixer -q set Master 5- > /dev/null 2>&1
                        ;;
                "$MAX")
			amixer -q set Master 100 > /dev/null 2>&1
                        ;;
                "$MUTE")
			amixer -q set Master toggle > /dev/null 2>&1
                        ;;
                *)
			killall ffplay > /dev/null 2>&1
			coproc( ffplay -loglevel 8 -nodisp ${url[$1]} > /dev/null 2>&1 )
			nowplaying=${url[$1]}
			exit 0
                        ;;
        esac
fi

volume=$(amixer get Master | sed -e '1,4d' -e 's/^.*[0-9\] \[//' -e 's/\].*//')
mutedisabled=$(amixer get Master | sed -e '1,4d' -e 's/^.*\[//' -e 's/\]//')

echo -en "\0message\x1f<b>Current volume:</b> $volume\n"
if [[ -n $nowplaying ]]; then
    	echo -en "$DISCONNECT\0permanent\x1true\n"
fi
	
COUNTER=1
for entry in "${stations[@]}"
do
    if [[ $nowplaying = ${url[$entry]} ]]
    then
	stationplaying=$entry
	echo -en "\0active\x1f$COUNTER\n"
        echo -en "$entry\0nonselectable\x1ftrue\n"
    	echo -en "\0markup-rows\x1ftrue\n"
        echo -en "\0message\x1f<b>Current volume:</b> $volume <b>Current station:</b> $stationplaying\n"
    else
    	echo -en "$entry\n"
    fi
    let COUNTER++
done

echo $UP
echo $DOWN
echo $MAX
let COUNTER+=3
if [[ $mutedisabled = "off" ]]; then
	echo -en "\0urgent\x1f$COUNTER\n"
	echo $MUTE
else
	echo $MUTE
fi

echo -e "\0no-custom\x1ftrue\n"
echo -en "\0prompt\x1fradio\n"
