# Everyone has different preferences of apps.
# This is a list of stuff I usually install

brew_apps=(
    nvm
    zsh
    yarn
    firefox
    google-chrome
    iterm2
    spotify
    sublime-text
    the-unarchiver
    visual-studio-code
    vlc
)

brew_fonts=(
    font-fira-code
    font-meslo-for-powerline
    font-meslo-lg
)

mas_apps=(
    #Amphetamine
    937984704
    #Magnet
    441258766
    #Xcode
    497799835
    #Craft

    #RunCat
    1429033973

    #Today
    #Pure Paste
)

npm_global_packages=(
    npm
)

echo "Installing brew apps"
brew install ${brew_apps[@]}

echo "Installing some brew fonts"
brew  install ${brew_fonts[@]}

brew cleanup

# NVM install NodeJS
nvm install v18.7.0
nvm use v18.7.0

echo "Installing Global NPM Packages"
npm install -g ${npm_global_packages[@]}


# Install Go Version Manager
echo "Installing Go Version Manager"
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# Install Go v1.21.4
echo "Installing Go v1.21.4"
gvm install go1.21.4 -B
gvm use go1.21.4
gvm list

echo "It's done!"
