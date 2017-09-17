#! /usr/bin/env bash
# see https://unix.stackexchange.com/questions/379747/uim-can-t-register-mozc-ubuntu
SOURCES_LIST=/etc/apt/sources.list
SOURCES_LIST_BAK="/tmp/sources.list-xenial-install-uim-mozc.bak"
cp -ai $SOURCES_LIST "$SOURCES_LIST_BAK"
tee -a $SOURCES_LIST <<< 'deb http://archive.ubuntu.com/ubuntu/ zesty main restricted universe multiverse'
SOURCES_LIST_MD5="$(md5sum $SOURCES_LIST)"
apt-get update
apt-get install uim-mozc uim-gtk2.0 uim-xim
if md5sum -c - <<< "$SOURCES_LIST_MD5"
then
	mv "$SOURCES_LIST_BAK" $SOURCES_LIST
	apt-get update
else
	echo $SOURCES_LIST has changed unexpectedly! Please manually remove the zesty entry.
	vim $SOURCES_LIST
	echo Please do apt-get update if done
fi
echo Now you can run uim-xim and uim-toolbar-gtk
