#! /usr/bin/env bash
xargs sudo apt-get install < apt-favorites \
&& sudo adduser $USER davfs2 \
&& newgrp davfs2 \
&& (
[[ -z "$BASH_IT" ]] \
	&& BASH_IT="$HOME/.bash_it" \
	&& git clone https://github.com/yuwash/bash-it.git "$BASH_IT" \
	&& "$BASH_IT"/install.sh
) \
&& source ~/.bashrc \
&& (
[[ -d /media/$USER ]] \
	|| sudo mkdir /media/$USER \
	&& sudo chown -R "$USER" /media/$USER \
	&& sudo chgrp -R "$USER" /media/$USER ) \
&& while read entry
do
	line="`envsubst <<<"$entry"`"
	target="`read -a tmp <<<"$line" \
		&& echo "${tmp[1]}"`"  # second entry in fstab is mount target
	grep "\<$target\>" /etc/fstab \
		|| sudo tee -a /etc/fstab <<<"$line"
done < fstab-append \
&& ( davencmount  # initialize
) \
&& (
	davfs2path="~/.davfs2"
	mkdir -p "$davfs2path"
	envsubst < davfs2secrets-append | tee -a "$davfs2path/secrets"
	chmod 600 "$davfs2path/secrets"
) \
&& ( davencmount p  # for the private files, defined for 'p'
) \
&& pdavtarget="`davencmount -l p | tail -n 1 | ( read -a tmp && echo ${tmp[-1]} )`" \
&& cp -ai "$pdavtarget/home/Documents/SSH/*" ~/.ssh \
&& chmod 600 ~/.ssh/*id_rsa \
&& gpg --import "$pdavtarget/home/Documents/PGP/*.asc" \
&& mkdir -p ~/.vim/bundle \
&& git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
&& vim ~/.vim/vimrc +'r ~/.vim/bundle/Vundle.vim/README.md' +'normal! gg/^\s*```vim$"_dgg/^\s*```$"_dGgg<Ggg/^\n\s*" All of your Pluginsk"_dapOk:r vundle-favoritesG:r vimrc-append' +'wq' \
&& vim +VundleInstall +only
