#!/usr/bin/env bash

if ! command -v ffplay 2>&1 >/dev/null; then
    echo "ffplay not found!"
    exit 0
fi

#
# Playlist file is yaml
# station name: "station url"
#

PLAYLIST="/home/pagrey/Music/playlist/playlist.yml"
FAVORITE="Cinemix"

if ! [[ -f $PLAYLIST ]]; then
    echo "No valid playlist found!"
    exit 0
fi

DISCONNECT="Disconnect"
PAD=" "
HTTP="//"
YAML=": "
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

declare -A url

while IFS= read -r line; do
    i=$(expr index "$line" $YAML)
    url["${line:0:$i-1}"]="${line:$i+2:${#line}-$i-3}"
done < $PLAYLIST

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
