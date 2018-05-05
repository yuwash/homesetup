#! /usr/bin/env bash

set -ex \
&& while read package
do package_data="$(jq ".[\"$package\"]" < custom-sources.json)"
	if [[ "true" == "$(echo $package_data | jq '. | has("ppa")')" ]]; then
		PPA=`echo $package_data | jq --raw-output '.ppa'` \
		&& sudo add-apt-repository ppa:$PPA
	elif [[ "true" == "$(echo $package_data | jq '. | has("repository")')" ]]; then
		if [[ "true" == "$(echo $package_data | jq '. | has("pubkey")')" ]]; then
			pubkey_url="$(echo $package_data | jq --raw-output '.pubkey.url')" \
			&& wget -qO - "$pubkey_url" | sudo apt-key add -
		fi \
		&& sudo add-apt-repository "$(echo $package_data | jq --raw-output '.repository')"
	fi
done < apt-custom \
&& sudo apt-get update \
&& sudo apt-get install `cat \
	apt-custom \
	# items below ignored \
	`
