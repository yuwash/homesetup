waitbell () {
	sleep $1
	play -q /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga \
		|| play -q /usr/share/sounds/gnome/default/alerts/bark.ogg \
		|| echo Completed but cannot play sound!
}

waitnotify () {
	sleep $1
	zenity --notification --text="$2"
}

foke () {
	OUT="${1%.f08}" && gfortran -o"$OUT" "$1" && echo $OUT
}

foker () {
	OUT="`foke "$1"`" && "./$OUT"
}
