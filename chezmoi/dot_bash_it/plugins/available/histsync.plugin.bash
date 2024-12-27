cite 'about-plugin'
about-plugin 'Bash history save and synchronization'

HFBASE="`basename $HISTFILE`"
HFBASE="${HFBASE#.}"


function _file_iso_date () {
	ls -l --time-style=long-iso "$1" | grep -m 1 -o '\<[[:digit:]]\{4\}\(-[[:digit:]]\{2\}\)\{2\}\>'
}


# quick way to synchronize history with other bash sessions
# from https://superuser.com/a/602405
function histsync () {
	about 'save and synchronize history'
	example '$ histsync'
	group 'histsync'

	history -a && history -c && history -r
	for target in "$@"
	do
		dest="$target/${HFBASE}-latest"
		if [[ -e "$dest" ]]
		then
			if [[ -f "$HISTFILE" ]]
			then
				if diff "$HISTFILE" "$dest"
				then echo skipping up-to-date destination $dest
				else suffix="-`_file_iso_date "$dest"`" \
					&& mv -i "$dest" "${dest%-latest}$suffix" \
					&& cp -ai "$HISTFILE" "$dest"
				fi
			else cp -ai "$dest" "$HISTFILE" \
				&& history -c && history -r
			fi
		fi
	done
}
