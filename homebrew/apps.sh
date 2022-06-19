# Everyone has different preferences of apps.
# This is a list of stuff I usually install
#

brew_apps=(
    nvm
    zsh
    yarn
    alfred
    1password
    firefox
    github
    google-chrome
    iterm2
    java
    postman
    spotify
    sublime-text
    the-unarchiver
    transmission
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
    #Bear
    1091189122
)

npm_global_packages=(
    now
    surge
)

echo "Installing brew apps..."
brew install ${brew_apps[@]}

echo "Installing some brew fonts..."
brew  install ${brew_fonts[@]}

brew cleanup

# NVM install NodeJS
nvm install v14.19.3
nvm use v14.19.3

echo "Installing Global NPM Packages..."
npm install -g ${npm_global_packages[@]}

echo "It's done!"