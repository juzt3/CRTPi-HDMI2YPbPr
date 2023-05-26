# when exiting an emulator -- revert to 1440x480i
vcgencmd hdmi_timings 1440 1 110 140 206 472 1 7 4 16 0 0 2 60 1 29862000 1 > /dev/null
tvservice -e "DMT 6" > /dev/null
tvservice -e "DMT 87" > /dev/null
sleep 0.1
fbset -depth 8 && fbset -depth 24 -xres 320 -yres 240 > /dev/null