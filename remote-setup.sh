#! /usr/bin/env bash
if [[ "$1" == '--redo' ]]; then
	REDO=true
	REMOTE_HOST="$2"
else
	REDO=false
	REMOTE_HOST="$1"
fi
REMOTE_USER=yuwash
SSHCONFIG="$HOME/.ssh/config"
HOMESETUP_BASEDIR=~/git/github-yuwash
HOMESETUP_GIT_REMOTE='https://github.com/yuwash/homesetup'
[[ -n "$VI" ]] || EDITOR=vim
{ ! "$REDO" && grep -q "Host\s*$REMOTE_HOST" "$SSHCONFIG"; } \
	|| { ssh "REMOTE_USER@REMOTE_HOST" \
		"echo logging in with $REMOTE_USER succeeded!" \
		&& { "$VI" "$SSHCONFIG" +"normal! GoHost $REMOTE_HOST  HostName $REMOTE_HOST  User $REMOTE_USER{j" \
			; echo 'Please run this again with the Host defined now' \
			; exit \
		; } \
	; } \
	|| { ssh "root@$REMOTE_HOST" "
		adduser '$REMOTE_USER' || passwd '$REMOTE_USER'
		usermod -aG sudo '$REMOTE_USER'
	"; } \
	|| exit $?
ssh "$REMOTE_HOST" "
	sudo apt-get update && sudo apt-get install git \
		&& mkdir -p $HOMESETUP_BASEDIR \
		&& cd $HOMESETUP_BASEDIR \
		&& git clone '$HOMESETUP_GIT_REMOTE' \
		&& bash -i"
