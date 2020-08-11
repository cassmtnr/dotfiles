# Everyone has different preferences of apps.
# This is a list of stuff I usually install
#

brew_apps=(
    mas
    nvm
    zsh
    zsh-completions
    watchmen
    yarn
)

cask_apps=(
    1password
    firefox
    github
    google-chrome
    google-backup-and-sync
    homebrew/cask-versions/hyper-canary
    itsycal
    java
    postman
    reactotron
    skype
    spotify
    sublime-text
    the-unarchiver
    transmission
    visual-studio-code
    vlc
)

brew_cask_fonts=(
    font-fira-code
    font-meslo-for-powerline
    font-meslo-lg
)

npm_global_packages=(
    now
    surge
)

mas_apps=(
    #Amphetamine
    937984704
    #Lightshot Screenshot
    526298438
    #Pages
    409201541
    #Keynote
    409183694
    #Trello
    1278508951
    #Magnet
    441258766
    #Xcode
    497799835
    #Numbers
    409203825
    #Unsplash Wallpapers
    1284863847
    #Bear
    1091189122
    #TheUnarchiver
    425424353
)

echo "Installing brew apps..."
brew install ${brew_apps[@]}

echo "Installing some brew cask apps..."
brew cask install ${cask_apps[@]}

echo "Installing some brew cask fonts..."
brew cask install ${brew_cask_fonts[@]}

brew cleanup

echo "Installing Global NPM Packages..."
npm install -g ${npm_global_packages[@]}

# WIP
# https://github.com/mas-cli/mas
# mas signin --dialog 'user' 'password'
# echo "Installing mac applications..."
# mas install ${mas_apps[@]}
# /WIP

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"

echo "It's done!"
