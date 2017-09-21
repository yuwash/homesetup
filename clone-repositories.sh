#! /usr/bin/env bash
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
done < git-favorites
