# when exiting an emulator -- revert to 1280x480i
vcgencmd hdmi_timings 1280 1 37 114 116 480 1 5 4 14 0 0 2 60 1 24365250 1 > /dev/null
tvservice -e "DMT 6" > /dev/null
tvservice -e "DMT 87" > /dev/null
sleep 0.1
fbset -depth 8 && fbset -depth 24 -xres 320 -yres 240 > /dev/null