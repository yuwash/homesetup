#! /usr/bin/env bash
sudo apt-get update \
&& sudo apt-get install `cat \
	apt-favorites \
	# items below ignored \
	apt-work \
	apt-extras \
	` \
&& sudo -H pip install -U pip \
&& pip install --user `cat \
	pip-favorites \
	# items below ignored \
	` \
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
fi
