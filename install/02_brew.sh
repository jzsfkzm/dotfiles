#/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install \
	ffmpeg \
	midnight-commander \
	nvm \
	util-linux \
	wget

brew cleanup

#
