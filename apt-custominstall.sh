#! /usr/bin/env bash

set -ex \
&& while read package
do PPA=`jq '.["'$package'"].ppa' < custom-sources.json` \
	&& PPA=${PPA//\"/} \
	&& sudo add-apt-repository ppa:$PPA
done < apt-custom \
&& sudo apt-get update \
&& sudo apt-get install `cat \
	apt-custom \
	# items below ignored \
	`
