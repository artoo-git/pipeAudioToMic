#!/bin/bash
set -e # exit immediately if a command exits wiht a non-zero status


if [ -z "$1" ]; then
        echo '------------------------------------------------------------'
        echo ''
        echo 'No playlist selected.'
        echo 'A playlist is a text file with a list of the filenames to play'
	echo 'Place mp3 songs in songs/ for the script to fetch them'
        echo ''
	echo ''
        echo 'use: pipe_audio2mic [playlistfile]'
        echo ''
        echo '------------------------------------------------------------'
        echo ''
else

	PLAYLIST=$1
	echo ''
	echo ''
	echo 'Playlist file:' $PLAYLIST
	LIST=$(cat $PLAYLIST)
	songN=1
	for SONG in $LIST
	do
		echo "$songN - $SONG"
		((songN = songN + 1))
	done

	echo ''
	echo ''
	echo ''


# Using module-null-sink I add a simple null sink. "All data written to this sink is silently dropped. This sink is clocked using the system time. All sinks have a corresponding "monitor" source which makes the null sink a practical way to plumb output to input."

# just resetting pulse (I know it's brutal but I need something quick atm)
pulseaudio -k #brutto reset to defaults

echo ''
echo ' adding null virtual module and the 2 loopbacks to pipe two sources into one'
echo ''
pactl load-module module-null-sink sink_name=Antani
pactl load-module module-loopback sink=Antani
pactl load-module module-loopback sink=Antani

	# I want choice to be a number or break out
	re='^[0-9]+$'	
	while :
	do
		echo ''
		echo 'Select song to play or type 0 to quit'
		read  CHOICE
		if ! [[ $CHOICE =~ $re ]]
		then
			echo ''
			echo 'quitting...' 
			echo ''
			echo 'Uninstalling the null module'
			pulseaudio -k # brutto reset to defaults
			#pactl unload-module module-loopback
			#pactl unload-module module-null-sink
			echo''
			echo 'Done. Bye'
			echo ''
			break
		fi
		echo ''
		SONG=$(sed -n "$CHOICE"p $PLAYLIST)
		echo 'canzone: '$SONG
		INPUT="songs/$SONG"
		echo ''
		mpv $INPUT
		echo 'Playlist'
		echo ''
		songN=1
		for SONG in $LIST
		do
			echo "$songN - $SONG"
			((songN = songN + 1))
		done


 
	done




fi
