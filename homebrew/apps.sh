# Everyone has different preferences of apps.
# This is a list of stuff I usually install

brew_cask_apps=(
    1password
    alfred
    android-studio
    beardedspice
    docker
    dropbox
    evernote
    firefox
    github
    google-chrome
    google-backup-and-sync
    hyper
    iterm2
    itsycal
    java
    loading
    megasync
    postman
    rocket
    slack
    sourcetree
    spotify
    statusfy
    steam
    sublime-text
    the-unarchiver
    transmission
    vanilla
    visual-studio-code
    vlc
)

brew_apps=(
    node
    yarn
    mas
    zsh
    zsh-completions
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
)

echo "installing brew apps..."
brew install ${brew_apps[@]}

echo "installing some brew cask apps..."
brew cask install ${brew_cask_apps[@]}

brew cleanup

# echo "installing mac applications..."
# https://github.com/mas-cli/mas
# mas signin --dialog 'user' 'password'
# mas install ${mas_apps[@]}


echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "It's done!"
