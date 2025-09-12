#!/usr/bin/env bash
set -e

secs=$((4*60))
while [ $secs -gt 0 ]
do
  sleep 1 &
  echo -en "\0prompt\x1f"
  printf "\r%02d:%02d:%02d" $((secs/3600)) $(( (secs/60)%60)) $((secs%60))
  secs=$(( $secs - 1 ))
  echo -e "$CANCEL" 
  wait
done

