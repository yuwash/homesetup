#! /usr/bin/env bash
set -ex \
&& source "$HOME/.bashrc" \
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
	do gpg --import "$key" || exit 1
done
