# Everyone has different preferences of apps.
# This is a list of stuff I usually install

  android-studio 
  1password
  alfred
  dropbox
  evernote
  firefox
  github
  google-chrome
  google-backup-and-sync
  hyper
  iterm2
  java
  slack
  sourcetree
  spotify
  sublime-text
  the-unarchiver
  transmission
  visual-studio-code
  vlc
)

brew_apps=(
  node,
  yarn,
  zsh,
  zsh-completions
)

# Install apps to /Applications
# Default is /Users/$user/Applications

echo "installing brew apps..."
brew install ${brew_apps[@]}

echo "installing some brew cask apps..."
brew cask install ${brew_cask_apps[@]}

brew cleanup

# link Alfred
brew cask alfred link

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "It's done!"
