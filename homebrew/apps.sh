## Define Homebrew apps

brew_apps=(
    google-chrome
    kitty
    nvm
    spotify
    the-unarchiver
    visual-studio-code
    vlc
    yarn
    zsh
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    mercurial
)

brew_fonts=(
    font-fira-code
    font-meslo-for-powerline
    font-meslo-lg
)

mas_apps=(
    #Amphetamine
    #Magnet
    #Xcode
    #Craft
    #RunCat
    #Pure Paste
    #Command X
)

npm_global_packages=(
    npm
)

echo "Installing brew apps"
brew install ${brew_apps[@]}

echo "Installing some brew fonts"
brew install ${brew_fonts[@]}

brew cleanup

# NVM install NodeJS
nvm install v21.7.2
nvm use v21.7.2

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