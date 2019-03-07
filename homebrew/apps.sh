# Everyone has different preferences of apps.
# This is a list of stuff I usually install

brew_cask_apps=(
    dropbox
    firefox
    github
    google-chrome
    google-backup-and-sync
    hyper
    itsycal
    java
    loading
    postman
    slack
    sourcetree
    spotify
    steam
    sublime-text
    the-unarchiver
    transmission
    visual-studio-code
    vlc
)

brew_apps=(
    ant
    gradle
    mas
    maven
    node
    yarn
    zsh
    zsh-completions
)

brew_cask_fonts=(
    font-fira-code
    font-meslo-for-powerline
    font-meslo-lg
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
)

echo "Installing brew apps..."
brew install ${brew_apps[@]}

echo "Installing some brew cask apps..."
brew cask install ${brew_cask_apps[@]}

echo "Installing some brew cask fonts..."
brew cask install ${brew_cask_fonts[@]}

brew cleanup

# WIP
# https://github.com/mas-cli/mas
# mas signin --dialog 'user' 'password'
echo "Installing mac applications..."
mas install ${mas_apps[@]}
# /WIP

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "It's done!"
