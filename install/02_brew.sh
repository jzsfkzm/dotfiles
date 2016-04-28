#/bin/bash

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php

brew install \
	ack \
	curl \
	dos2unix \
	git \
	mc \
	mysql \
	node \
	nvm \
	php56 \
	unrar \
	wget

#
