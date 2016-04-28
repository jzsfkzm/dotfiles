#/bin/bash

brew install caskroom/cask/brew-cask
brew cask install --appdir=/Applications \
	1password \
	atom \
	caffeine \
	calibre \
	chicken \
	daisydisk \
	firefox \
	gimp \
	gitup \
	google-chrome \
	hipchat \
	iterm2 \
	java \
	mou \
	slack \
	steam \
	sublime-text \
	transmission \
	vagrant \
	virtualbox \
	vlc

brew cask cleanup

#
