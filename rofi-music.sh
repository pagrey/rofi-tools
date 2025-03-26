#!/usr/bin/env bash

if ! command -v ffplay 2>&1 >/dev/null; then
    echo "ffplay not found!"
    exit 0
fi

DISCONNECT="Disconnect"
PAD=" "
FAVORITE="Cinemix"

declare -rA url=(["Radio Dismuke"]="http://stream1.early1900s.org:8080"
["1920s Radio Network"]="http://208.85.242.72:8398"
["1940s Radio"]="http://199.189.111.28:8012"
["1940s UK Radio"]="http://91.121.134.23:8100"
["Big Blue Swing"]="http://209.236.126.18:8002"
["Electro Lounge"]="https://electrolounge.stream.laut.fm/electrolounge?pl=pls&t302=2024-08-26_23-57-55&uuid=ba9e3f02-429f-4659-9ae5-acf6715fb367"
["Lounge Radio"]="http://nl1.streamhosting.ch:80"
["Venice Classical"]="http://116.202.241.212:8010"
["Instrumental Hits Radio"]="https://panel.retrolandigital.com:8130/listen"
["Cinemix"]="http://51.81.46.118:1190")

nowplaying=$(ps hw -C ffplay -o args= | sed -e 's/^.*nodisp //')

if [[ $# -gt 0 ]]; then
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
    	echo -e "$DISCONNECT\0permanent\x1ftrue"
fi

if [[ $nowplaying = ${url["$FAVORITE"]} ]]; then
	stationplaying="$FAVORITE"
	echo -e "\0active\x1f1"
    echo -e "$FAVORITE\0display\x1f$PAD$FAVORITE\x1fnonselectable\x1ftrue"
else
	echo -e "$FAVORITE\0display\x1f$PAD$FAVORITE"
fi

COUNTER=2
	
for entry in "${!url[@]}"
do
    if [[ "$entry" != $FAVORITE ]]; then
		if [[ $nowplaying = ${url["$entry"]} ]]; then
			stationplaying="$entry"
			echo -e "\0active\x1f$COUNTER"
			echo -e "$entry\0display\x1f$PAD$entry\x1fnonselectable\x1ftrue"
		else
			echo -e "$entry\0display\x1f$PAD$entry"
		fi
		let COUNTER++
    fi
done

echo -e "\0no-custom\x1ftrue"
echo -e "\0prompt\x1fradio"

if command -v amixer 2>&1 >/dev/null; then
    volume=$(amixer -M get Master | sed -e '1,4d' -e 's/^.*[0-9\] \[//' -e 's/\].*//')
    if [[ -n $nowplaying ]]; then
        echo -e "\0message\x1f $stationplaying playing, volume: $volume"
    else
        echo -e "\0message\x1f Nothing playing, volume: $volume"
    fi
else
    if [[ -n $nowplaying ]]; then
			echo -e "\0message\x1f<b>Current station:</b> $stationplaying"
	else
        echo -e "\0message\x1f Nothing playing"
	fi
fi
