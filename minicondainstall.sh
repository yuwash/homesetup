#!/usr/bin/env bash
MINICONDA3_64_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
MINICONDA3_32_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86.sh"
INSTALLERFILE="$(basename "$MINICONDA3_64_URL")"
wget -O"$INSTALLERFILE" "$MINICONDA3_64_URL" \
	&& bash "$INSTALLERFILE"
