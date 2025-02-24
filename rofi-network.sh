#!/usr/bin/env bash

WIRELESS="wlan0"
WIRED="enp0s31f6"
STATICIP="192.168.254.80"
ROUTE="192.168.254.254"
SCAN="Scan..."
STARTWIRELESS="Enable Wifi"
STOPWIRELESS="Disable Wifi"
CONFIGWIRELESS=" scan..."
DISCONNECTWIRELESS="Disconnect"
STARTWIRED="Enable LAN"
STOPWIRED="Disable LAN"
IFS=$'\n'
PAD="  "
IL="&#91;"
IR="&#93;"
NL="&lt;"
NR="&gt;"
NF="not found"
ICON_PATH="~/.config/rofi/icons/"
ICON_ETHERNET="settings_ethernet_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_WIFI="network_wifi_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_WIFI_OFF="signal_wifi_off_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_WIFI_BAD="signal_wifi_bad_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_WIFI_NULL="signal_wifi_statusbar_null_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_WIFI_FIND="wifi_find_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_STOP="close_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_RULE="horizontal_rule_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_SEARCH="search_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"
ICON_CLOSE="close_18dp_FFFFFF_FILL0_wght400_GRAD0_opsz20.svg"

show_menu () {
	if ip link show $WIRED | grep -qs "[<,]UP[,>]"; then
		# wired up
		SIP=$(ip addr show $WIRED | grep inet | awk '{print $2}')
		echo -e "\0no-custom\x1ftrue"
		echo -e "\0prompt\x1fnetwork"
		echo -e "\0message\x1f<b>Connected</b>:$SIP"
		echo -e "$STOPWIRED\0display\x1f$STOPWIRED $IL$WIRED up$IR\x1ficon\x1f$ICON_PATH$ICON_ETHERNET"
		echo -e "$STARTWIRELESS\0display\x1f$STARTWIRELESS $IL$WIRELESS down$IR\x1ficon\x1f$ICON_PATH$ICON_RULE"
		exit 0
	elif ip link show $WIRELESS | grep -qs "[,]UP[,>]"; then
		# wireless up
		SIP=$(ip addr show $WIRELESS | grep inet | awk '{print $2}')
		echo -e "\0no-custom\x1ftrue"
		echo -e "\0prompt\x1fnetwork"
		echo -e "\0message\x1f<b>Connected</b>:$SIP"
		echo -e "$STARTWIRED\0display\x1f$STARTWIRED $IL$WIRED down$IR\x1ficon\x1f$ICON_PATH$ICON_RULE"
		echo -e "$STOPWIRELESS\0display\x1f$STOPWIRELESS $IL$WIRELESS up$IR\x1ficon\x1f$ICON_PATH$ICON_WIFI_OFF"
		echo -e "$CONFIGWIRELESS\0icon\x1f$ICON_PATH$ICON_WIFI_FIND"
		exit 0
	else
		echo -e "\0no-custom\x1ftrue"
		echo -e "\0prompt\x1fnetwork"
		echo -e "$STARTWIRED\0display\x1f$STARTWIRED $IL$WIRED down$IR\x1ficon\x1f$ICON_PATH$ICON_RULE"
		echo -e "$STARTWIRELESS\0display\x1f$STARTWIRELESS $IL$WIRELESS down$IR\x1ficon\x1f$ICON_PATH$ICON_RULE"
		exit 0
	fi
}

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

echo -e "\0markup-rows\x1ftrue"

if [ $# -gt 0 ]
then
        case "$1" in
                "$DISCONNECTWIRELESS")
                        iwctl station $WIRELESS disconnect
			exit 0
                        ;;
		"$STARTWIRELESS")
			if ip link show $WIRED | grep -qs "[,]UP[,>]"; then
				sudo ip address flush dev $WIRED
				sudo ip route flush dev $WIRED
				sudo ip link set $WIRED down
			fi
			sudo ip link set $WIRELESS up
			# start iwd and scan
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
			if ip link show $WIRELESS | grep -qs "[,]UP[,>]"; then
				sudo ip link set $WIRELESS down
			fi
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
                "$CONFIGWIRELESS")
                        ;;
                *)
                        NEW_NETWORK="$@"
			get_known_networks
			if [[ "$IW_KNOWN" =~ "$NEW_NETWORK" ]]; then
				iwctl station $WIRELESS connect "$NEW_NETWORK" 
			else
					echo -e "\0no-custom\x1ffalse"
					echo -e "\0data\x1f$NEW_NETWORK"
					echo -e "\0prompt\x1fnetwork"
					echo -e "\0message\x1fEnter password for $NEW_NETWORK"
					echo -e "password"
			fi
			exit 0
                        ;;
        esac
else
	show_menu
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

echo -e "\0prompt\x1fnetwork"
if [[ -n $@ && "$1" = "$SCAN" ]]; then
	WORKING_LIST="$IW_NETWORKS"
	echo -e "\0message\x1fAvailable wireless networks"
else
	WORKING_LIST="$IW_KNOWN"
	echo -e "\0message\x1fSaved wireless networks"
fi

echo -e "$SCAN\0permanent\x1ftrue\x1fdisplay\x1f$CONFIGWIRELESS\x1ficon\x1f$ICON_PATH$ICON_SEARCH"

CON_STATE=$(iwctl station $WIRELESS show)

# List SSID 

COUNTER=1
while IFS= read -r line; do
	if [[ -n $@ && "$1" = "$SCAN" ]]; then
        	line=${line:0}
	else
        	line=${line:2}
	fi
	SSID_NAME=$(echo "$line" | sed -e 's/\(\s*psk.*\)//' -e 's/\(\s*open.*\)//')
        if [[ $IW_NETWORKS =~ $SSID_NAME ]]; then
		if [[ -n "$CURR_SSID"  &&  "$SSID_NAME" = "$CURR_SSID" ]]; then
			echo -e "${SSID_NAME}\0display\x1f$PAD<b>${SSID_NAME}</b> $NL$CURR_IP$NR\x1fnonselectable\x1ftrue\x1ficon\x1f$ICON_PATH$ICON_WIFI"
			echo -e "\0active\x1f$COUNTER"
		else
			echo -e "${SSID_NAME}\0display\x1f$PAD${SSID_NAME}\x1fnonselectable\x1ffalse\x1ficon\x1f$ICON_PATH$ICON_RULE"
		fi
		let COUNTER++
	else
		echo -e "${SSID_NAME}\0display\x1f$PAD${SSID_NAME} $NL$NF$NR\x1fnonselectable\x1ftrue\x1ficon\x1f$ICON_PATH$ICON_WIFI_BAD"
		let COUNTER++
	fi
done <<< "$WORKING_LIST"
if [[ "$CON_STATE" =~ " connected" ]]; then
	echo -e "$DISCONNECTWIRELESS\0permanent\x1ftrue\x1fnonselectable\x1ffalse\x1fdisplay\x1f$DISCONNECTWIRELESS from $CURR_SSID\x1ficon\x1f$ICON_PATH$ICON_WIFI_OFF"
fi
echo -e "$STOPWIRELESS\0permanent\x1ftrue\x1fdisplay\x1f$STOPWIRELESS $IL$WIRELESS up$IR\x1ficon\x1f$ICON_PATH$ICON_STOP"

