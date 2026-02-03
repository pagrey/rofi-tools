#!/usr/bin/env bash
set -eu

DEFAULT="600"
RESET="10 minutes ($DEFAULT)"
DISABLE="Disable"
ACTIVATE="Activate"
OFF="0"

#
# Wayland
#
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
  if ! command -v swayidle 2>&1 >/dev/null; then
      echo "swayidle not found!"
      exit 0
  fi
  if [[ $# -gt 0 ]]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
      killall swayidle && while pgrep -l swayidle; do sleep 1;done;
      coproc( swayidle -w timeout $1 "swaymsg output eDP-1 power off" resume "swaymsg output eDP-1 power on" > /dev/null 2>&1 )
      exit 0
    else
      case "$1" in
  "$ACTIVATE")
    killall swayidle && while pgrep -l swayidle; do sleep 1;done;
    coproc( swayidle -w timeout $DEFAULT "swaymsg output eDP-1 power off" resume "swaymsg output eDP-1 power on" > /dev/null 2>&1 )
    swaymsg output eDP-1 power off > /dev/null 2>&1
    until pids=$(pidof swayidle)
    do   
      sleep 1
    done
    sleep 1
    kill -SIGUSR1 $pids > /dev/null 2>&1
    exit 0
    ;;
  "$RESET")
    killall swayidle && while pgrep -l swayidle; do sleep 1;done;
    coproc( swayidle -w timeout $DEFAULT "swaymsg output eDP-1 power off" resume "swaymsg output eDP-1 power on" > /dev/null 2>&1 )
    exit 0
    ;;
  "$DISABLE")
    killall swayidle> /dev/null 2>&1
    exit 0
    ;;
      esac
    fi
  fi

  timeout=`ps x | grep swayidle | sed -n '/output/p' | sed -e 's/^.*timeout //' | sed -e  's/^\([0-9]\+\).*/\1/'`
  if ![[ $timeout =~ ^[0-9]+$ ]]; then
    standby=$OFF
  else
    standby=$timeout
  fi
else
#
#  X11
#
  if ! command -v xset 2>&1 >/dev/null; then
    echo "xset not found!"
    exit 0
  fi

  if [[ $# -gt 0 ]]; then
    if [[ $1 =~ ^[0-9]+$ ]]; then
      xset dpms $1 $1 $1
      xset s $1 $1
      exit 0
    else
      case "$1" in
        "$ACTIVATE")
          xset dpms $DEFAULT $DEFAULT $DEFAULT 
          xset s $DEFAULT $DEFAULT 
          sleep 0.25 && xset s activate
          exit 0
          ;;
        "$RESET")
          xset dpms $DEFAULT $DEFAULT $DEFAULT 
          xset s $DEFAULT $DEFAULT 
          exit 0
          ;;
        "$DISABLE")
          xset dpms $OFF $OFF $OFF
          xset s $OFF $OFF
          exit 0
          ;;
      esac
    fi
  fi

  standby=`xset q | sed -n -e '/Standby/p' | sed -e 's/.*[^0-9]\([0-9]\+\)[^0-9]*$/\1/'`
  timeout=`xset q | sed -n -e '/timeout/p' | sed -e 's/.*[^0-9]\([0-9]\+\)[^0-9]*$/\1/'`
fi

echo -e "\0prompt\x1fscreensaver timeout"
echo -e "\0markup-rows\x1ftrue"
echo -e "\0keep-selection\x1ftrue"
if [[ $standby != $OFF ]]; then
  echo -e "\0message\x1f<b>Current timeout:</b> $standby"
else
  echo -e "\0message\x1f<b>Current timeout:</b> disabled"
fi

echo -e "$ACTIVATE\n$RESET\n$DISABLE"

