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

# Extras:
# install_python_packages
# setup_vundle
# setup_tmux

# Finally, run after-bashit.sh
bash --login after-bashit.sh
