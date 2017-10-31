#! /usr/bin/env bash
if [[ -z "$1" ]]
then REPOLISTF=git-favorites  # default
else if [[ -e "$1" ]]
then REPOLISTF="$1"
else
	echo $0: $1: No such file
	exit 1
fi
fi
REPOROOT="$HOME/git" \
&& while read entry
do ( group="`python repo-group-name.py "$entry"`" \
	&& mkdir -p "$REPOROOT/$group" \
	&& repopath="$REPOROOT/$group/`python repo-group-name.py -N "$entry"`" \
	&& if [[ -d "$repopath" ]]
	then echo "$repopath already exists; skipping"
	else git clone "$entry" "$repopath"
	fi \
) || exit $?
done < "$REPOLISTF"
