#! /usr/bin/env bash
# Run this from your terminal.
# The following will add our apt repository and install the CLI:
sudo add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./" \
&& { curl -L https://cli-assets.heroku.com/apt/release.key | sudo apt-key add -
} \
&& sudo apt-get install apt-transport-https \
&& sudo apt-get update \
&& sudo apt-get install heroku
