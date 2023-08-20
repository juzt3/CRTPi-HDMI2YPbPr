#!/usr/bin/env bash
#=====================================================================================================================================
#title           :   runcommand-onstart.sh
#description     :   This script perform the following - #Mike Vencio
#			Determines if the game being run is a console or an arcade/fba
#			For arcades, it will dynamically determine the resolution based on MAME resolution.ini file
#			For consoles, hdmi_timings can be set based on emulator or system
#			Dynamically creates the game_name.zip.cfg file and sets the custom_viewport_height for MAME/FBA/NeoGeo
#			Dynamically add these parameters (video_allow_rotate = "true" and video_rotation = 1) for vertical games
#			vertical.txt contains all the mame 0.184 vertical games
#			Ability to set custom_viewport_width for MAME/FBA/NeoGeo
#			Fix arcade custom_viewport_width for 320x224 and 320x240 resolutions
#			Added amiga and C64 support
#	                Automatically set custom_viewport_y to center vertically (Removed on 0.7.1)
#			Added support for 480 height arcade games like tapper
#			Disable resolution change for non libretto cores
#			Added support for 448 height arcade games like popeye
#			Added support for 254 height arcade games like mk3
#			Arcade/FBA/Mame-Libretro/NeoGeo - Set custom_viewport_width to be rom_resolution_width closest to 1920
#			Removed text output when running scripts
#			Reverted hdmi_timings to previous version
#			Removed all logging
#			Default non supported non-lr emulators to 320x240
#			Default non supported lr- emulators to 1600x240p - #CRTpi-Project
#			Added config-per core scripting to change between 2048x224p / 2048x240p / 2048x192p - #CRTPi-Project
#			Added config-per core scripting to change between 1920x224p / 1920x240p / 1920x200p / 1920x192p - #CRTPi-Project
#			Added per-game user scripting using heavily modified Sakitoshi tv-out script - #CRTPi-Project
#og. author	:  Michael Vencio
#ad. author	:  Sakitoshi
#revision	:  CRTPi-Project v3.1
#rev. author    :  http://reddit.com/r/u_erantyint
#rev. date	:  July10-2020
#notes          :  For advance users only and would need to be tweaked to cater to your needs and preference
#		   resolution.ini (MAME 0.184) file needed http://www.progettosnaps.net/renameset/
#=====================================================================================================================================

#### Michael Vencio ####

# get the system name
system=$1

# get the emulator name
emul=$2
emul_lr=${emul:0:2}

# get the full path filename of the ROM
rom_fp=$3
rom_bn=$3

# Game or Rom name
rom_bn="${rom_bn%.*}"
rom_bn="${rom_bn##*/}"

#### Sakitoshi X CRTPi ####

#If Value found in 256.txt for Consoles
if [ -f "/opt/retropie/configs/$1/256.txt" ]; then 
	TwoFiveSix=$(tr -d "\r" < "/opt/retropie/configs/$1/256.txt" | sed -e 's/\[/\\\[/'); 
fi > /dev/null

#If Value found in 256.txt for Ports
if [ -f "/opt/retropie/configs/ports/$1/256.txt" ]; then 
	TwoFiveSix=$(tr -d "\r" < "/opt/retropie/configs/ports/$1/256.txt" | sed -e 's/\[/\\\[/'); 
fi > /dev/null

# If 256.txt is Empty
if [ ! -s "/opt/retropie/configs/$1/256.txt" ] && [ ! -s "/opt/retropie/configs/ports/$1/256.txt" ] || [ -z "$TwoFiveSix" ]; then 
	TwoFiveSix="empty"; 
fi > /dev/null

#If Value found in 320.txt for Consoles
if [ -f "/opt/retropie/configs/$1/320.txt" ]; then 
	ThreeTwenty=$(tr -d "\r" < "/opt/retropie/configs/$1/320.txt" | sed -e 's/\[/\\\[/'); 
fi > /dev/null

#If Value found in 320.txt for Ports
if [ -f "/opt/retropie/configs/ports/$1/320.txt" ]; then 
	ThreeTwenty=$(tr -d "\r" < "/opt/retropie/configs/ports/$1/320.txt" | sed -e 's/\[/\\\[/'); 
fi > /dev/null

# If 320.txt is Empty
if [ ! -s "/opt/retropie/configs/$1/320.txt" ] && [ ! -s "/opt/retropie/configs/ports/$1/320.txt" ] || [ -z "$ThreeTwenty" ]; 
	then ThreeTwenty="empty"; 
fi > /dev/null

#### Michael Vencio ####

# Determine if arcade or fba then determine resolution, set hdmi_timings else goto console section
if [[ "$system" == "arcade" ]] || [[ "$system" == "fba" ]] || [[ "$system" == "mame-libretro" ]] || [[ "$system" == "neogeo" ]] ; then
	# get the line number matching the rom
	rom_ln=$(tac /opt/retropie/configs/all/resolution.ini | grep -w -n $rom_bn | cut -f1 -d":")
	
	# get resolution of rom
	rom_resolution=$(tac /opt/retropie/configs/all/resolution.ini | sed -n "$rom_ln,$ p" | grep -m 1 -F '[') 
	rom_resolution=${rom_resolution#"["}
	rom_resolution=${rom_resolution//]}
	rom_resolution=$(echo $rom_resolution | sed -e 's/\r//g')
	rom_resolution_width=$(echo $rom_resolution | cut -f1 -d"x")
	rom_resolution_height=$(echo $rom_resolution | cut -f2 -d"x")
	
# Set rom_resolution_height for 480p and 448p roms
	if [ $rom_resolution_height == "480" ]; then
		rom_resolution_height="240"
	elif [ $rom_resolution_height == "448" ]; then
		rom_resolution_height="224"
	fi	
	
# Create rom_name.cfg
	if ! [ -f "$rom_fp"".cfg" ]; then 
		touch "$rom_fp"".cfg" 
	fi
	
# Set custom_viewport_height
	if ! grep -q "custom_viewport_height" "$rom_fp"".cfg"; then
		echo -e "custom_viewport_height = ""\"$rom_resolution_height\"" >> "$rom_fp"".cfg" 2>&1
	fi
	
# determine if vertical  
	if grep -w "$rom_bn" /opt/retropie/configs/all/vertical.txt ; then 
		# Add vertical parameters (video_allow_rotate = "true")
		if ! grep -q "video_allow_rotate" "$rom_fp"".cfg"; then
			echo -e "video_allow_rotate = \"true\"" >> "$rom_fp"".cfg" 2>&1
		fi
		
		# Add vertical parameters (video_rotation = 3)
		if ! grep -q "video_rotation" "$rom_fp"".cfg"; then
			echo -e "video_rotation = \"3\"" >> "$rom_fp"".cfg" 2>&1
		fi	
		
		# Add integer scale parameters (video_scale_integer = true)
		if ! grep -q "video_scale_integer" "$rom_fp"".cfg"; then
			echo -e "video_scale_integer = \"true\"" >> "$rom_fp"".cfg" 2>&1
		fi
	fi

# set the custom_viewport_width 
	if ! grep -q "custom_viewport_width" "$rom_fp"".cfg"; then 
		echo -e "custom_viewport_width = ""\"1920\"" >> "$rom_fp"".cfg"  2>&1
	fi
fi

#### Michael Vencio X CRTPi ####

# determine and set variable resolutions for libretto cores
if [[ "$emul_lr" == "lr" ]]; then
	# re-get the system name
	system=$1
	
# change timings for 256.txt to 2048x240p
	if { ! echo "$3" | grep -q -wi "$ThreeTwenty" || echo "$ThreeTwenty" | grep -q empty; } && ! echo "$ThreeTwenty" | grep -q -xi "all" && { echo "$3" | grep -q -wi "$TwoFiveSix"; } then > /dev/null
		vcgencmd hdmi_timings 2048 1 160 202 320 240 1 3 5 14 0 0 0 60 0 42954545 1 > /dev/null; #CRTPi 2048x240p Timing Adjusted
		tvservice -e "DMT 6" > /dev/null;
		tvservice -e "DMT 87" > /dev/null;
		sleep 0.1
		fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 2048 -yres 240 > /dev/null; #24b depth
		
# change timings for 320.txt to 1920x240p
	elif { ! echo "$3" | grep -q -wi "$TwoFiveSix" || echo "$TwoFiveSix" | grep -q empty; } && ! echo "$TwoFiveSix" | grep -q -xi "all" && { echo "$3" | grep -q -wi "$ThreeTwenty"; } then > /dev/null
		vcgencmd hdmi_timings 1920 1 137 247 295 240 1 3 7 12 0 0 0 60 0 40860000 1 > /dev/null #CRTPi 1920x240p Timing Adjusted
		tvservice -e "DMT 6" > /dev/null;
		tvservice -e "DMT 87" > /dev/null;
		sleep 0.1
		fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1920 -yres 240 > /dev/null #24b depth
		
# change timings for 256x224 systems to 2048x224p
	elif 
		[[ "$system" == "snes" ]] || 
		[[ "$system" == "nes" ]] || 
		[[ "$system" == "romhacks" ]] ; then
			# vcgencmd hdmi_timings 2048 1 160 202 320 224 1 11 5 22 0 0 0 60 0 42954545 1 > /dev/null #CRTPi 2048x224p Timing Adjusted
			vcgencmd hdmi_timings 2048 1 59 183 186 224 1 13 3 22 0 0 0 60 0 38929335 1 > /dev/null
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 2048 -yres 224 > /dev/null #24b depth
			
# change timings for 256x240 systems to 2048x240p
	elif 
		[[ "$system" == "fds" ]] || 
		[[ "$system" == "pcengine" ]] || 
		[[ "$system" == "pce-cd" ]] ||
		[[ "$system" == "ngp" ]] || 
		[[ "$system" == "ngpc" ]] || 
		[[ "$system" == "gb" ]] || 
		[[ "$system" == "gbc" ]] || 
		[[ "$system" == "gba" ]] || 
		[[ "$system" == "psp" ]] || 		
		[[ "$system" == "gamegear" ]] || 
		[[ "$system" == "virtualboy" ]] || 
		[[ "$system" == "atarilynx" ]] || 
		[[ "$system" == "wonderswan" ]] || 
		[[ "$system" == "wonderswancolor" ]] ; then
			vcgencmd hdmi_timings 2048 1 160 202 320 240 1 3 5 14 0 0 0 60 0 42954545 1 > /dev/null #CRTPi 2048x240p Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 2048 -yres 240 > /dev/null #24b depth
			
# change timings for 256x192 systems to 2048x192p
	elif 		
		[[ "$system" == "mastersystem" ]] || 
		[[ "$system" == "sg-1000" ]] ; then
			vcgencmd hdmi_timings 2048 1 160 202 320 192 1 27 5 38 0 0 0 60 0 42954545 1 > /dev/null #CRTPi 2048x192p Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 2048 -yres 192 > /dev/null #24b depth
			
# change timings for 320x224 & 384x224 systems to 1920x224p
	elif 
		[[ "$system" == "megadrive" ]] || 
		[[ "$system" == "segacd" ]] || 
		[[ "$system" == "sega32x" ]] || 
		[[ "$system" == "fba" ]] || 
		[[ "$system" == "neogeo" ]] ; then
			vcgencmd hdmi_timings 1920 1 137 247 295 224 1 11 7 20 0 0 0 60 0 40860000 1 > /dev/null #CRTPi 1920x224p Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1920 -yres 224 > /dev/null #24b depth
			
# change timings for 320x200 systems to 1920x200p
	elif 
		[[ "$system" == "quake" ]] || 
		[[ "$system" == "doom" ]] ; then
			vcgencmd hdmi_timings 1920 1 137 247 295 200 1 23 7 32 0 0 0 60 0 40860000 1 > /dev/null #CRTPi 1920x200p Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1920 -yres 200 > /dev/null #24b depth
			
# change timings for 320x192 systems to 1920x192p
	elif 
		[[ "$system" == "atari2600" ]] || 
		[[ "$system" == "atari5200" ]] || 
		[[ "$system" == "atari800" ]] || 
		[[ "$system" == "amiga" ]] || 
		[[ "$system" == "zxspectrum" ]] ; then
			vcgencmd hdmi_timings 1920 1 137 247 295 192 1 27 7 36 0 0 0 60 0 40860000 1 > /dev/null #CRTPi 1920x192p Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1920 -yres 192 > /dev/null #24b depth
			
# change timings for 320x240 systems to 1920x240p
	elif 
		[[ "$system" == "psx" ]] || 
		[[ "$system" == "saturn" ]] || 
		[[ "$system" == "atari7800" ]] || 
		[[ "$system" == "n64" ]] || 
		[[ "$system" == "arcade" ]] || 
		[[ "$system" == "mame-libretro" ]] || 
		[[ "$system" == "cavestory" ]] ; then 
			vcgencmd hdmi_timings 1920 1 137 247 295 240 1 3 7 12 0 0 0 60 0 40860000 1 > /dev/null #CRTPi 1920x240p Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1920 -yres 240 > /dev/null #24b depth

# change timmings for 640x480p systens to 640x480i
	elif 
		[[ "$system" == "dreamcast" ]] ; then
			vcgencmd hdmi_timings 1280 1 101 127 209 480 1 5 4 14 0 0 2 60 1 27042750 1 > /dev/null #CRTPi 640x480i Timing Adjusted
			tvservice -e "DMT 6" > /dev/null;
			tvservice -e "DMT 87" > /dev/null;
			sleep 0.1
			fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1280 -yres 480 > /dev/null #24b depth
			
# default to 1600x240p for all other lr- systems
	else
		vcgencmd hdmi_timings 1600 1 73 157 204 240 1 4 3 15 0 0 0 60 0 32000000 1 > /dev/null #CRTPi 1600x240p Timing Adjusted
		tvservice -e "DMT 6" > /dev/null;
		tvservice -e "DMT 87" > /dev/null;
		sleep 0.1
		fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 1600 -yres 240 > /dev/null #24b depth
	fi

# otherwise -- determine and set variable resolutions for non-libretto cores	
elif
# for eDuke32 switch to 320x200p
	[[ "$system" == "eduke32" ]] ||
	[[ "$system" == "duke3d" ]] ||
	[[ "$system" == "scummvm" ]] ||
	[[ "$system" == "dosbox" ]] ||
	[[ "$system" == "pc" ]] ||
	[[ "$system" == "c64" ]] ; then
	vcgencmd hdmi_timings 320 1 10 30 40 200 1 28 3 36 0 0 0 60 0 6400000 1 > /dev/null #CRTPi 320x200p Adjusted
	tvservice -e "DMT 6" > /dev/null;
	tvservice -e "DMT 87" > /dev/null;
	sleep 0.1
	fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 320 -yres 200 > /dev/null #24b depth
	
else
# for all other non-libretro emulators switch to 640x480i
	vcgencmd hdmi_timings  1280 1 101 127 209 480 1 5 4 14 0 0 2 60 1 27042750 1 > /dev/null
	tvservice -e "DMT 6" > /dev/null;
	tvservice -e "DMT 87" > /dev/null;
	sleep 0.1
	fbset -depth 8 && fbset -depth 16 && fbset -depth 24 -xres 320 -yres 240 > /dev/null #24b depth
fi

#####