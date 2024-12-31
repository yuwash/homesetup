#!/usr/bin/env bash
NPM_CONFIG_PREFIX=~/.joplin-bin npm install -g joplin &&
mkdir -p ~/.local/bin &&
ln -s ~/.joplin-bin/bin/joplin ~/.local/bin/joplin
