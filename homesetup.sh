#! /usr/bin/env bash
set -ex
for g in $USER user
do grep -q $g <(groups) \
	&& MYGRP=$g \
	&& break
done
for f in \
	/etc/default/keyboard \
	/etc/X11/xorg.conf.d/00-keyboard.conf
do [[ -f "$f" ]] \
	&& KEYCONF_FILE="$f" \
	&& break
done \
&& ( grep -q colemak "$KEYCONF_FILE" \
	|| sudo vim "$KEYCONF_FILE" \
		+'%s/^\c\(XKBLAYOUT\).*$/\1="us"' \
		+'%s/^\c\(XKBVARIANT\).*$/\1="colemak"' \
		+'%s/^\c\(XKBOPTIONS\).*$/\1="grp:caps_toggle,grp_led:scroll"' \
) \
&& udevadm trigger --subsystem-match=input --action=change \
&& if type apt-get > /dev/null
then sudo apt-get update \
&& sudo apt-get install `cat \
	apt-favorites \
	# items below ignored \
	apt-work \
	apt-extras \
	`
else if type pacman > /dev/null
then sudo pacman -Sy --needed `cat \
	pacman-favorites \
	# items below ignored \
	`
fi
fi \
&& for g in davfs2 network docker
do if ! (groups | grep -q $g)
then
	( grep -q ^$g /etc/group \
		|| sudo groupadd $g ) \
	&& sudo usermod -aG $g "$USER" \
	&& ( newgrp $g; true )
	# non-zero expected for newgrp command
fi || exit $?
done \
&& sudo -H pip install -U pip \
&& pip install --user `cat \
	pip-favorites \
	# items below ignored \
	` \
&& if ! [[ -d /media/$USER ]]
then
	sudo mkdir -p /media/$USER \
	&& sudo chown -R "$USER" /media/$USER \
	&& sudo chgrp -R "$MYGRP" /media/$USER
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
