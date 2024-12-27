#! /usr/bin/env bash
set -ex
for g in $USER user
do grep -q $g <(groups) \
	&& MYGRP=$g \
	&& break
done

# Source the functions file
source homesetup_functions.sh

# Call the functions in order
configure_keyboard
install_packages
add_groups davfs2 network docker
setup_directories_and_fstab
install_bash_it
update_bashrc

# Enable bash-it
source "$HOME"/.bashrc
source "$BASH_IT"/bash_it.sh

enable_bash_it_plugins

# Extras:
# install_python_packages
# setup_vundle
# setup_spacevim
# setup_tmux

echo please '`reload`, `newgrp davfs2` (may need `sudo gpasswd -r davfs2`)' and run ./after-davencmount.sh
