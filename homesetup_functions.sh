configure_keyboard() {
    local keyconf_file
    for f in \
        /etc/default/keyboard \
        /etc/X11/xorg.conf.d/00-keyboard.conf
    do
        [[ -f "$f" ]] && keyconf_file="$f" && break
    done

    if [[ -n "$keyconf_file" ]]; then
        grep -q colemak "$keyconf_file" \
            || sudo vi "$keyconf_file" \
            +'s/^\(\s*XKBLAYOUT\).*$/\1="us,us"/' \
            +'s/^\(\s*XKBVARIANT\).*$/\1="colemak,altgr-intl"/' \
            +'s/^\(\s*XKBOPTIONS\).*$/\1="grp:win_space_toggle"/'
        sudo udevadm trigger --subsystem-match=input --action=change
    else
        echo "Keyboard configuration file not found, skipped."
    fi
}

install_packages() {
    if type apt-get > /dev/null
        then sudo apt-get update
        sudo apt-get install $(cat \
            apt-essentials \
            # items below ignored \
            apt-favorites \
            apt-work \
            apt-extras \
            )
    elif type pacman > /dev/null
    then sudo pacman -Sy --needed $(cat
        pacman-favorites
        # items below ignored \
        )
    fi
}

add_groups() {
    for g in "$@"
        do if ! (groups | grep -q "$g")
            then grep -q ^"$g" /etc/group \
                || sudo groupadd "$g"
            sudo usermod -aG "$g" "$USER"
        fi || exit $?
    done
}

install_python_packages() {
    local pip_packages
    readarray pip_packages < <(cat \
        pip-favorites \
        # items below ignored \
        )
    if [[ -n "${pip_packages[@]}" ]]; then
        sudo -H pip install -U pip
        pip install --user "${pip_packages[@]}"
    fi
}

setup_directories_and_fstab() {
    sudo mkdir -p /media/"$USER"
    sudo chown "$USER" /media/"$USER"
    sudo chgrp "$MYGRP" /media/"$USER"
    mkdir -p /media/"$USER"/davfs

    while read entry
    do
        line="$(envsubst <<<"$entry")"
        target="$(read -a tmp <<<"$line" && echo "${tmp[1]}")"
        grep "$target" /etc/fstab || sudo tee -a /etc/fstab <<<"$line"
        [[ -d "$target" ]] || mkdir -p "$target"
    done < fstab-append
}

setup_tmux() {
    if [[ -f "$HOME/.tmux.conf" ]]
    then echo "$HOME/.tmux.conf already exists, leaving unchanged."
    else tee "$HOME/.tmux.conf" <<< 'set-option -g mode-keys vi
set-option -g status-bg green
set-window-option -g pane-active-border-style fg=green
bind-key -T prefix '\'\"\'' split-window -c "#{pane_current_path}"
bind-key -T prefix % split-window -h -c "#{pane_current_path}"
bind-key -T prefix c new-window -c "#{pane_current_path}"'
    fi
}

setup_vundle() {
    if ! [[ -d "$HOME/.vim/bundle" ]]
    then
        mkdir -p "$HOME/.vim/bundle"
        git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
        vim ~/.vim/vimrc +'r ~/.vim/bundle/Vundle.vim/README.md' +'normal! gg/^\s*```vim$
"_dgg/^\s*```$
"_dGgg<Ggg/^\n\s*" All of your Plugins
k"_dapOk:r vundle-favorites
G:r vimrc-append
' +'wq' \
	&& view - +'new' <<< 'Please run
:VundleInstall
:set spell'
    fi
}

install_bash_it() {
    if [[ -z "$BASH_IT" ]]; then
        BASH_IT="$HOME/.bash_it"
        git clone https://github.com/yuwash/bash-it.git "$BASH_IT"
    fi &&
    if ! type bash-it
    then "$BASH_IT"/install.sh
    fi
}

update_bashrc() {
    vim "$HOME/.bashrc" +'%s/BASH_IT_THEME.*$'"/BASH_IT_THEME='densecandy'/"
}

enable_bash_it_plugins() {
  bash-it enable plugin \
    davencmount \
    histsync \
    # returns 0 even if already enabled
}
