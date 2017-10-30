#! /usr/bin/env bash
set -ex \
&& ( bash-it enable plugin \
	davencmount \
	histsync \
	# returns 0 even if already enabled
) \
&& echo please '`reload`' and run ./after-davencmount.sh
