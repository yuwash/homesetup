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
install_python_packages
setup_directories_and_fstab
setup_tmux
setup_vundle
install_bash_it
update_bashrc

# Finally, run after-bashit.sh
bash --login after-bashit.sh
