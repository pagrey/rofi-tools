#!/usr/bin/env bash

DEVICE="wlan0"
DISCONNECT="Disconnect"
SCAN="Scan networks"
IFS=$'\n'

get_known_networks () {
IW_KNOWN=$(iwctl known-networks list | sed -e '/^--/d' -e 1,4d | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
}
get_networks () {
	IW_NETWORKS=$(iwctl station $DEVICE get-networks | sed -e '/^--/d' -e 1,4d | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
	NETWORK_LIST=""
	while IFS= read -r line; do
		line=${line:6}
		SSID_NAME=$(echo "$line" | sed -e 's/\(\s*psk.*\)//' -e 's/\(\s*open.*\)//')
		line=""
		line+=$SSID_NAME
		line+=$'\n'
		NETWORK_LIST+=$line
	done <<< "$IW_NETWORKS"
	IW_NETWORKS=$(echo "$NETWORK_LIST" | sed '$d')
}

# connect to new network with password
if [[ -n $ROFI_DATA ]]; then
	iwctl --passphrase="$@" station $DEVICE connect "$ROFI_DATA"
	exit 0
fi

if [ $# -gt 0 ]
then
        case "$1" in
                "$DISCONNECT")
                        iwctl station $DEVICE disconnect
			exit 0
                        ;;
                "$SCAN")
                        ;;
                *)
                        NEW_NETWORK="$@"
			get_known_networks
			if [[ "$IW_KNOWN" =~ "$NEW_NETWORK" ]]; then
				iwctl station $DEVICE connect "$NEW_NETWORK" 
			else
					echo -e "\0no-custom\x1ffalse"
					echo -e "\0data\x1f$NEW_NETWORK"
					echo -en "\0prompt\x1finternet\n"
					echo -en "\0message\x1fEnter password for $NEW_NETWORK\n"
					echo -en "password\n"
			fi
			exit 0
                        ;;
        esac
else
	# start iwd and scan
	while [[ -n $(iwctl station $DEVICE scan) ]]; do
		sleep 0.25
	done
fi

CURR_SSID=$(iwctl station $DEVICE show | sed -n 's/^\s*Connected\snetwork\s*\(\S*\)\s*$/\1/p')
CURR_IP=$(iwctl station $DEVICE show | sed -n 's/^\s*IPv4\saddress\s*\(\S*\)\s*$/\1/p')

echo -e "\0no-custom\x1ftrue"
if [[ -n $CURR_SSID && -n $CURR_IP ]]; then
	SSID_MESSAGE="Connected to $CURR_SSID"
else
	SSID_MESSAGE=""
fi

get_known_networks

get_networks

echo -en "\0prompt\x1finternet\n"
if [[ -n $@ && "$1" = "$SCAN" ]]; then
	WORKING_LIST="$IW_NETWORKS"
	echo -en "\0message\x1fAvailable wireless networks\n"
else
	WORKING_LIST="$IW_KNOWN"
	echo -en "\0message\x1fSaved wireless networks\n"
fi

echo -en "\0markup-rows\x1ftrue\n"

CON_STATE=$(iwctl station $DEVICE show)
if [[ "$CON_STATE" =~ " connected" ]]; then
	echo -en "$DISCONNECT\0nonselectable\x1ffalse\n"
fi

echo -en "$SCAN\n"


# List SSID 

COUNTER=2
while IFS= read -r line; do
	if [[ -n $@ && "$1" = "$SCAN" ]]; then
        	line=${line:0}
	else
        	line=${line:2}
	fi
	SSID_NAME=$(echo "$line" | sed -e 's/\(\s*psk.*\)//' -e 's/\(\s*open.*\)//')
        if [[ $IW_NETWORKS =~ $SSID_NAME ]]; then
		if [[ -n "$CURR_SSID"  &&  "$SSID_NAME" = "$CURR_SSID" ]]; then
			echo -en "<b>${SSID_NAME}</b> &lt;$CURR_IP&gt;\0nonselectable\x1ftrue\n"
			echo -en "\0active\x1f$COUNTER\n"
		else
			echo -en "${SSID_NAME}\0nonselectable\x1ffalse\n"
		fi
		let COUNTER++
	else
		echo -en "${SSID_NAME} &lt;not found&gt;\0nonselectable\x1ftrue\n"
		let COUNTER++
	fi
done <<< "$WORKING_LIST"

