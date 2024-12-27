cite 'about-plugin'
about-plugin 'mount davfs2 and encfs or gocryptfs as configured in ~/.davencmount'

DAVENCMOUNT_FILE="$HOME/.davencmount"


function _grepmany_first_word () {
	if [[ "$#" = 0 ]]
	then
		tee
		return $?
	fi
	args=()
	n=0
	for pattern in "$@"
	do
		args[$n]=-e
		args[$((n+1))]="^$pattern"
		n=$((n+2))
	done
	grep -w "${args[@]}"
}


function _mounted () {
	if ! [[ -z $2 ]]
	then echo _mounted ignoring surplus arguments $2 ..
	fi
	line=`grep "$1" /etc/mtab` && echo already mounted: $line
}


function _choose () {
	choices="$1"
	[[ -z "$choices" ]] && return 1  # choices can't be empty
	defchoice="`grep -o '[[:upper:]]' <<< "$choices"`"
	((1 >= ${#defchoice})) || return 1  # only one default choice supported
	hint="`sed -e 's/\w/&\//g' -e 's/\/$//' <<< $choices`"
	shift
	echo -n "$@ ($hint) " > /dev/tty
	while true
	do
		read -n 1 ans
		if [[ -z "$ans" ]] && ! [[ -z "$defchoice" ]]
		then
			echo $defchoice
			return
		fi
		echo > /dev/tty  # finish last prompt line
		while read -n 1 c
		do if grep -qi $c <<< "$ans"
		then
			echo $c
			return
		fi
		done <<< "$choices"
		echo "Unrecognized option '$ans'" > /dev/tty
		echo -n "Please choose one of ($hint) " > /dev/tty
	done
}


function _confirm () {
	choice="`_choose Yn $@`"
	[[ "$choice" = Y ]]
}


function _try_mount_or_mkdir () {
	"$@" || {
		ret="$?"
		target_dir="${@:$#}"
		if [[ -e "$target_dir" ]] || ! _confirm "Create directory $target_dir?"
		then
			return $ret
		fi
		mkdir -p "$target_dir" || {
			sudo mkdir -p "$target_dir" \
			&& sudo chown $USER "$target_dir"
		}
		"$@"
	}
}


function davencmount () {
	about 'mount as configured in ~/.davencmount'
	example '$ davencmount mytarget'
	group 'davencmount'

	[[ -e "$DAVENCMOUNT_FILE" ]] || if _confirm "davencmount configuration file at $DAVENCMOUNT_FILE doesn't exist. Create?"
	then 
		touch "$DAVENCMOUNT_FILE"
		assume_yes=''
		while read line
		do
			target="`read -a tmp <<<"$line" && echo "${tmp[1]}"`"  # second entry in fstab is mount target
			if [[ "$assume_yes" = Y ]]
			then ans=Y
			else
				ans="`_choose Yanq "add target $target? (yes/all/no/quit)" < /dev/tty`"
				case "$ans" in
					(a) ans=Y; assume_yes=Y;;
					(q) break;;
				esac
			fi
			if [[ "$ans" = Y ]]
			then
				echo -n "Give a unique shorthand for $target: "
				while true
				do
					read shorthand < /dev/tty
					if grep -q '^[[:alnum:]]\+$' <<< "$shorthand"
					then
						tee -a "$DAVENCMOUNT_FILE" <<< "$shorthand $target"
						break
					else echo -n 'Please only use alphanumeric characters: '
					fi
				done
			fi
		done < <(grep '^[^# ]\+\s\+/\S\+\s*davfs' < /etc/fstab)
	else
		echo davencmount doesn\'t work without configuration file\; aborting.
		return 2
	fi
	if [[ "$1" = -l ]]
	then
		shift
		_grepmany_first_word "$@" < "$DAVENCMOUNT_FILE"
		return $?
	fi
	unmount=''
	for target in "$@"
	do if [[ "$target" = -u ]]
	then
		unmount='yes'
	else if [[ -z "$unmount" ]]
	then 
		grep "^$target\>" "$DAVENCMOUNT_FILE" | while read entry
		do etmp="`envsubst <<<"$entry"`" && read -a earr <<<"$etmp"
			if [[ -z "${earr[1]}" ]]
			then echo error at $entry; return 1
			fi
			if [[ "${earr[1]}" = encfs ]] || [[ "${earr[1]}" = gocryptfs ]]
			then _mounted "${earr[-1]}" || {
				_try_mount_or_mkdir \
					${earr[@]:1} < /dev/tty
        # This works because the first word (encfs, gocryptfs) is the
        # command and the second one (path) its argument.
			}
			else if [[ "${earr[1]}" = sshfs ]]
			then _mounted "${earr[-1]}" || {
				_try_mount_or_mkdir \
					sshfs ${earr[@]:2} < /dev/tty
			}
			else _mounted "${earr[-1]}" || { mount ${earr[@]:1} < /dev/tty; }
			fi
			fi || { 
				ret=$?
				echo failed at $target ${earr[@]:1}
				return $?
			}
		done
	else
		grep "^$target\>" "$DAVENCMOUNT_FILE" | tac - | while read entry
		do etmp="`envsubst <<<"$entry"`" && read -a earr <<<"$etmp"
			if [[ -z "${earr[1]}" ]]
			then echo error at $entry; return 1
			fi
			if [[ "${earr[1]}" = encfs ]] || [[ "${earr[1]}" = gocryptfs ]] || [[ "${earr[1]}" = sshfs ]]
			then _mounted "${earr[-1]}" && { fusermount -u "${earr[-1]}" < /dev/tty; }
			else _mounted "${earr[-1]}" && { fusermount -u "${earr[-1]}" < /dev/tty; }
			fi || echo skipping unmounting possibly failed $target ${earr[-1]}
		done
	fi
	unmount=''
	fi
	done
}
