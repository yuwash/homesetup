#! /usr/bin/env bash
( grep -q colemak /etc/default/keyboard \
	|| sudo vim /etc/default/keyboard \
		+'%s/^XKBLAYOUT.*$/XKBLAYOUT="us"' \
		+'%s/^XKBVARIANT.*$/XKBVARIANT="colemak"' \
		+'%s/^XKBOPTIONS.*$/XKBOPTIONS="grp:caps_toggle,grp_led:scroll"' \
) \
&& udevadm trigger --subsystem-match=input --action=change \
&& sudo apt-get install `cat apt-favorites` \
&& if ! (groups | grep -q davfs2)
then
	sudo adduser "$USER" davfs2
	# not && because non-zero expected for adduser command
	newgrp davfs2
fi \
&& if [[ -z "$BASH_IT" ]]
then
	BASH_IT="$HOME/.bash_it" \
	&& git clone https://github.com/yuwash/bash-it.git "$BASH_IT" \
	&& "$BASH_IT"/install.sh
fi \
&& vim "$HOME/.bashrc" +'%s/BASH_IT_THEME.*$'"/BASH_IT_THEME='densecandy'/" \
&& source "$HOME/.bashrc" \
&& ( bash-it enable plugin davencmount  # returns 0 even if already enabled
) \
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
&& ( davencmount  # initialize
) \
&& (
	davfs2path="$HOME/.davfs2"
	mkdir -p "$davfs2path"
	envsubst < davfs2secrets-append | tee -a "$davfs2path/secrets"
	chmod 600 "$davfs2path/secrets"
) \
&& ( davencmount -l p \
	|| vim "$HOME/.davencmount" +'normal! Gop PLEASE DEFINE FOR PRIVATE FILES'
) \
&& ( davencmount p  # for the private files, defined for 'p'
) \
&& pdavtarget="`davencmount -l p | tail -n 1 | ( read -a tmp && echo ${tmp[-1]} )`" \
&& cp -ariT "$pdavtarget/home/Documents/SSH" "$HOME/.ssh" \
&& chmod 600 ~/.ssh/*id_rsa \
&& find "$pdavtarget/home/Documents/PGP" -name '*.asc' | while read key
	do gpg --import "$key"
done \
&& if ! [[ -d "$HOME/.vim/bundle" ]]
then
	mkdir -p "$HOME/.vim/bundle" \
	&& git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim" \
	&& vim ~/.vim/vimrc +'r ~/.vim/bundle/Vundle.vim/README.md' +'normal! gg/^\s*```vim$"_dgg/^\s*```$"_dGgg<Ggg/^\n\s*" All of your Pluginsk"_dapOk:r vundle-favoritesG:r vimrc-append' +'wq' \
	&& vim +PluginInstall +only
fi
