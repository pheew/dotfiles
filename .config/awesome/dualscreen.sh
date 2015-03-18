#!/bin/bash

#Usage: "dual-screen" sets your laptop screen (LVDS1) as primary screen and the other display (HDMI1 or VGA1) on its right, "dual-screen l" is the same but left sided.

case $1 in
"l")
	position="--left-of";;
"2")
	position="--above";;
"3")
	position="--right-of";;
*)
	position="--below";;
esac
if [ `xrandr | grep -c ' connected '` -eq 2 ]; then # dual-monitor
    echo -n "Dual screen: "
    if [ `xrandr | grep VGA1 | grep -c ' connected '` -eq 1 ]; then
        echo "VGA1 +  LVDS1"
        xrandr --output VGA1 --auto --output LVDS1 --auto --primary $position VGA1
    fi
    if [ `xrandr | grep HDMI1 | grep -c ' connected '` -eq 1 ]; then
        echo "HDMI1 + LVDS1"
        xrandr --output HDMI1 --auto --output LVDS1 --auto --primary $position HDMI1
    fi
else
    echo "Single screen: LVDS1"
xrandr --output LVDS1 --auto --primary --output VGA1 --off --output HDMI1 --off
fi
