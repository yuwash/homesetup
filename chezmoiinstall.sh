#!/usr/bin/env bash
if ! type chezmoi >/dev/null 2>&1
then sh -c "$(wget -qO- get.chezmoi.io)"
fi &&
if [[ ! -d ~/.local/share/chezmoi ]]
then chezmoi init --apply .
fi
