#!/usr/bin/env bash

if ! command -v ffplay 2>&1 >/dev/null; then
    echo "ffplay not found!"
    exit 0
fi

declare -rA url=(["Radio Dismuke"]="http://stream1.early1900s.org:8080"
["1920s Radio Network"]="http://208.85.242.72:8398"
["1940s UK Radio"]="http://91.121.134.23:8100"
["Big Blue Swing"]="http://209.236.126.18:8002"
["Electro Lounge"]="https://electrolounge.stream.laut.fm/electrolounge?pl=pls"
["Lounge Radio"]="http://nl1.streamhosting.ch:80"
["Venice Classical"]="http://116.202.241.212:8010"
["Instrumental Hits Radio"]="https://panel.retrolandigital.com:8130/listen"
["Bluegrass Country"]="https://ice24.securenetsystems.net/WAMU"
["The Bluegrass Jamboree"]="https://s2.radio.co/sf0dcfa39a/listen"
["Traditional Classic Country"]="http://207.244.126.86:7713/stream"
["Cinemix"]="http://51.81.46.118:1190")

FAVORITE="Cinemix"

DISCONNECT="Disconnect"
PAD=" "
HTTP="//"
SHORTLENGTH=25

print_row(){
    address=${url["$entry"]}
    i=$(expr index "$address" "$HTTP")
    if [[ ${#address} -gt $SHORTLENGTH ]]; then
	shorturl="${address:$i+1:$SHORTLENGTH}..."
    else
	shorturl="${address:$i+1}"
    fi
    if [[ $nowplaying = $address ]]; then
	stationplaying="$entry"
	echo -e "\0active\x1f$COUNTER"
	echo -e "$entry\0display\x1f$PAD$entry <span color='#555'> $shorturl</span>\x1fnonselectable\x1ftrue"
    else
	echo -e "$entry\0display\x1f$PAD$entry <span color='#555'> $shorturl</span>"
    fi
}

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

entry=$FAVORITE
COUNTER=1
print_row
let COUNTER++

for entry in "${!url[@]}"
do
    if [[ "$entry" != $FAVORITE ]]; then
	print_row
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
