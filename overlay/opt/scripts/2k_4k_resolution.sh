#!/usr/bin/env bash
###
# File: 2k_4k_resolution.sh
# Project: scripts
###


#cvt 1600 900 60
#xrandr --newmode WHAT_THE_LINE_ABOVE_TELLS_YOU
#eg. xrandr --newmode "3440x1440_60.00" 419.50 3440 3696 4064 4688 1440 1443 1453 1493 -hsync +vsync

#laptop hp
xrandr --newmode "1600x900_60.00"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
xrandr --addmode HDMI-A-2 1600x900_60.00

#34 po widescreen, 1440p
xrandr --newmode "3440x1440_60.00" 419.50 3440 3696 4064 4688 1440 1443 1453 1493 -hsync +vsync
xrandr --addmode HDMI-A-2 3440x1440_60.00

#27 po, 4k
xrandr --newmode "3840x2160_60.00"  712.75  3840 4160 4576 5312  2160 2163 2168 2237 -hsync +vsync
xrandr --addmode HDMI-A-2 3840x2160_60.00

xrandr --newmode "2560x1440_60.00" 312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync
xrandr --addmode HDMI-A-2 2560x1440_60.00

#nexus 9
xrandr --newmode "2048x1536_60.00"  267.25  2048 2208 2424 2800  1536 1539 1543 1592 -hsync +vsync
xrandr --addmode HDMI-A-2 2048x1536_60.00

#samsung s20+
xrandr --newmode "3200x1440_60.00"  389.50  3200 3432 3776 4352  1440 1443 1453 1493 -hsync +vsync
xrandr --addmode HDMI-A-2 3200x1440_60.00

#surface pro 3
xrandr --newmode "2160x1440_60.00"  263.50  2160 2320 2552 2944  1440 1443 1453 1493 -hsync +vsync
xrandr --addmode HDMI-A-2 2160x1440_60.00
