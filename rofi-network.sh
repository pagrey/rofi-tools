#!/usr/bin/env bash

WIRELESS="wlan0"
WIRED="enp0s31f6"
STATICIP="192.168.254.80"
ROUTE="192.168.254.254"
SCAN="Scan networks"
STARTWIRELESS="Wireless ON"
STOPWIRELESS="Wireless OFF"
DISCONNECTWIRELESS="Disconnect"
STARTWIRED="Ethernet ON"
STOPWIRED="Ethernet OFF"
IFS=$'\n'

get_known_networks () {
IW_KNOWN=$(iwctl known-networks list | sed -e '/^--/d' -e 1,4d | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
}
get_networks () {
	IW_NETWORKS=$(iwctl station $WIRELESS get-networks | sed -e '/^--/d' -e 1,4d | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
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
	iwctl --passphrase="$@" station $WIRELESS connect "$ROFI_DATA"
	exit 0
fi

if [ $# -gt 0 ]
then
        case "$1" in
                "$DISCONNECTWIRELESS")
                        iwctl station $WIRELESS disconnect
			exit 0
                        ;;
		"$STARTWIRELESS")
			# start iwd and scan
			sudo ip address flush dev $WIRED
			sudo ip route flush dev $WIRED
			sudo ip link set $WIRED down
			sudo ip link set $WIRELESS up
			while [[ -n $(iwctl station $WIRELESS scan) ]]; do
				sleep 0.25
			done
			;;
		"$STOPWIRELESS")
                        iwctl station $WIRELESS disconnect
			sudo ip link set $WIRELESS down
			exit 0
			;;
		"$STARTWIRED")
			sudo ip link set $WIRELESS down
			sudo ip link set $WIRED up
			sudo ip address add $STATICIP/24 brd + dev $WIRED
			sudo ip route add default via $ROUTE dev $WIRED
			exit 0
			;;
		"$STOPWIRED")
			sudo ip address flush dev $WIRED
			sudo ip route flush dev $WIRED
			sudo ip link set $WIRED down
			exit 0
			;;
                "$SCAN")
                        ;;
                *)
                        NEW_NETWORK="$@"
			get_known_networks
			if [[ "$IW_KNOWN" =~ "$NEW_NETWORK" ]]; then
				iwctl station $WIRELESS connect "$NEW_NETWORK" 
			else
					echo -e "\0no-custom\x1ffalse"
					echo -e "\0data\x1f$NEW_NETWORK"
					echo -en "\0prompt\x1fnetwork\n"
					echo -en "\0message\x1fEnter password for $NEW_NETWORK\n"
					echo -en "password\n"
			fi
			exit 0
                        ;;
        esac
else
	if ip link show $WIRED | grep -qs "[<,]UP[,>]"; then
		# wired up
		SIP=$(ip addr show enp0s31f6 | grep inet | awk '{print $2}')
		echo -e "\0no-custom\x1ftrue"
		echo -en "\0prompt\x1fnetwork\n"
		echo -en "\0message\x1fconnected:$SIP\n"
		echo -en "$STOPWIRED\n"
		echo -en "$STARTWIRELESS\n"
		exit 0
	elif ! ip link show $WIRELESS | grep -qs "[,]UP[,>]"; then
		echo -e "\0no-custom\x1ftrue"
		echo -en "\0prompt\x1fnetwork\n"
		echo -en "$STARTWIRED\n"
		echo -en "$STARTWIRELESS\n"
		exit 0
	fi
fi

CURR_SSID=$(iwctl station $WIRELESS show | sed -n 's/^\s*Connected\snetwork\s*\(\S*\)\s*$/\1/p')
CURR_IP=$(iwctl station $WIRELESS show | sed -n 's/^\s*IPv4\saddress\s*\(\S*\)\s*$/\1/p')

echo -e "\0no-custom\x1ftrue"
if [[ -n $CURR_SSID && -n $CURR_IP ]]; then
	SSID_MESSAGE="Connected to $CURR_SSID"
else
	SSID_MESSAGE=""
fi

get_known_networks

get_networks

echo -en "\0prompt\x1fnetwork\n"
if [[ -n $@ && "$1" = "$SCAN" ]]; then
	WORKING_LIST="$IW_NETWORKS"
	echo -en "\0message\x1fAvailable wireless networks\n"
else
	WORKING_LIST="$IW_KNOWN"
	echo -en "\0message\x1fSaved wireless networks\n"
fi

echo -en "\0markup-rows\x1ftrue\n"

CON_STATE=$(iwctl station $WIRELESS show)
if [[ "$CON_STATE" =~ " connected" ]]; then
	echo -en "$DISCONNECTWIRELESS\0nonselectable\x1ffalse\n"
fi

echo -en "$SCAN\n"
echo -en "$STOPWIRELESS\n"


# List SSID 

COUNTER=3
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

