export ZSH=$HOME/.oh-my-zsh

export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export JAVA_HOME=$(/usr/libexec/java_home)

# Loads Java JDK
export PATH="/usr/local/opt/openjdk/bin:$PATH"

ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
    git
    node
    npm
    osx
)

ZSH_DISABLE_COMPFIX="true"
UPDATE_ZSH_DAYS=30
DISABLE_AUTO_UPDATE="true"

source $ZSH/oh-my-zsh.sh


mkd () {
    mkdir -p "$@" && cd "$@"
}

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

###########
# ALIASES #
###########

alias zrc="code ~/dotfiles/zsh/.zshrc"
alias dot="cd ~/dotfiles && code ."
alias dotfiles="cd ~/dotfiles"

# Easier navigation: .., ..., ...., .....

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias cls="clear"

# Shortcuts

alias d="cd ~/Documents"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dev="cd ~/Dev"
alias g="git"
alias stash="git stash"
alias pop="git stash pop"
alias status="git status"
alias n="npm"
alias ns="npm run start"
alias y="yarn"
alias add="yarn add "
alias ys="yarn start"
alias rm-node="rm -rf node_modules && rm -rf package-lock.json && rm -rf yarn.lock"
alias reinstall="rm-node && npm install"
alias ip="netstat -rn | grep default"
alias sshq="code ~/.ssh"
alias ip="ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}'"

alias kfz="cd ~/Work/kfz-frontend"
alias kfz-start="cd ~/Work/kfz-frontend && npm run start:local-t380"
# alias kfz-start="cd ~/Work/kfz-frontend && npm run start:local-staging"

alias run-ios="react-native run-ios"
alias run-android="react-native run-android"
alias avd="~/Library/Android/sdk/emulator/emulator -avd Pixel2"

# Get OS X Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade --all; brew cleanup; npm install npm -g; npm update -g'

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Disable Spotlight
alias spotoff="sudo mdutil -a -i off"
# Enable Spotlight
alias spoton="sudo mdutil -a -i on"


# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"


# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"


eval $(ssh-agent)
# ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/github


# Loads NVM
export NVM_DIR="$HOME/.nvm"
NVM_SRC="/usr/local/opt/nvm"
[ -s "$NVM_SRC/nvm.sh" ] && . "$NVM_SRC/nvm.sh"  # This loads nvm
[ -s "$NVM_SRC/etc/bash_completion.d/nvm" ] && . "$NVM_SRC/etc/bash_completion.d/nvm" # This loads nvm bash_completion

clear
