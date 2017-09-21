#! /usr/bin/env bash
( grep -q colemak /etc/default/keyboard \
	|| sudo vim /etc/default/keyboard \
		+'%s/^XKBLAYOUT.*$/XKBLAYOUT="us"' \
		+'%s/^XKBVARIANT.*$/XKBVARIANT="colemak"' \
		+'%s/^XKBOPTIONS.*$/XKBOPTIONS="grp:caps_toggle,grp_led:scroll"' \
) \
&& udevadm trigger --subsystem-match=input --action=change \
&& sudo apt-get update \
&& sudo apt-get install `cat \
	apt-favorites \
	# items below ignored \
	apt-work \
	apt-extras \
	` \
&& if ! (groups | grep -q davfs2)
then
	sudo adduser "$USER" davfs2
	# not && because non-zero expected for adduser command
	newgrp davfs2
fi \
&& sudo -H pip install -U pip \
&& pip install --user `cat \
	pip-favorites \
	# items below ignored \
	` \
&& if ! [[ -d /media/$USER ]]
then
	sudo mkdir /media/$USER \
	&& sudo chown -R "$USER" /media/$USER \
	&& sudo chgrp -R "$USER" /media/$USER
fi \
&& mkdir -p /media/$USER/davfs \
&& while read entry
do
	line="`envsubst <<<"$entry"`"
	target="`read -a tmp <<<"$line" \
		&& echo "${tmp[1]}"`"  # second entry in fstab is mount target
	grep "$target" /etc/fstab \
		|| sudo tee -a /etc/fstab <<<"$line" \
		|| exit $?
	[[ -d "$target" ]] \
		|| mkdir -p "$target" \
		|| exit $?
done < fstab-append \
&& if [[ -f "$HOME/.tmux.conf" ]]
then echo "$HOME/.tmux.conf" already exists, leaving unchanged
else tee "$HOME/.tmux.conf" <<< 'set-option -g mode-keys vi
set-option -g mode-keys vi
set-option -g status-bg green
set-window-option -g pane-active-border-style fg=green
bind-key    -T prefix '\'\"\''              split-window -c "#{pane_current_path}"
bind-key    -T prefix %                split-window -h -c "#{pane_current_path}"
bind-key    -T prefix c                new-window -c "#{pane_current_path}"'
fi \
&& if ! [[ -d "$HOME/.vim/bundle" ]]
then
	mkdir -p "$HOME/.vim/bundle" \
	&& git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim" \
	&& vim ~/.vim/vimrc +'r ~/.vim/bundle/Vundle.vim/README.md' +'normal! gg/^\s*```vim$"_dgg/^\s*```$"_dGgg<Ggg/^\n\s*" All of your Pluginsk"_dapOk:r vundle-favoritesG:r vimrc-append' +'wq' \
	&& vim +PluginInstall +only
fi \
&& if [[ -z "$BASH_IT" ]]
then
	BASH_IT="$HOME/.bash_it" \
	&& git clone https://github.com/yuwash/bash-it.git "$BASH_IT" \
	&& "$BASH_IT"/install.sh
fi \
&& vim "$HOME/.bashrc" +'%s/BASH_IT_THEME.*$'"/BASH_IT_THEME='densecandy'/" \
&& echo Please source '"$HOME/.bashrc"' and run ./after-bashit.sh
