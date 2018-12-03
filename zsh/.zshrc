export ZSH=$HOME/.oh-my-zsh

export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export JAVA_HOME=$(/usr/libexec/java_home)

export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle
export ANDROID_HOME=/usr/local/share/android-sdk
export ANDROID_NDK_HOME=/usr/local/share/android-ndk
export INTEL_HAXM_HOME=/usr/local/Caskroom/intel-haxm

export PATH=$ANT_HOME/bin:$PATH
export PATH=$MAVEN_HOME/bin:$PATH
export PATH=$GRADLE_HOME/bin:$PATH
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/build-tools/23.0.1:$PATH

export PATH="/Users/cassiano/bin/Sencha/Cmd:$PATH"

ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
    git,
    node,
    npm,
    osx
)

source $ZSH/oh-my-zsh.sh

export UPDATE_ZSH_DAYS=1

function mkd() {
    mkdir -p "$@" && cd "$@"
}

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

###########
# ALIASES #
###########

alias zrc="code ~/Dropbox/Dev/dotfiles/zsh/.zshrc"
alias dot="cd ~/Dropbox/Dev/dotfiles && code ."

# Easier navigation: .., ..., ...., .....

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias cls="clear"

# Shortcuts

alias d="cd ~/Documents/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dev="cd ~/Dropbox/Dev"
alias utfpr="cd ~/Google\ Drive/UTFPR/Engenharia\ de\ Software/4º\ Período/"
alias g="git"
alias stash="git stash"
alias pop="git stash pop"
alias stt="git status"
alias n="npm"
alias ns="npm run start"
alias y="yarn"
alias add="yarn add "
alias ys="yarn start"
alias rm-node="rm -rf node_modules"
alias ip="netstat -rn | grep default"
alias ssh="code ~/.ssh"


alias ciss="cd ~/ciss"
# alias ciss-start='ciss && cd ciss-live-frontend-workspace && docker run --rm -it --name extjs -v "$(pwd)":/src -p1841:1841 dockerhub.ciss.com.br/dev-extjs'
alias ciss-start='ciss && cd ciss-live-frontend-workspace/ciss-live-frontend && sencha app watch --uses'
alias ciss-stop="docker stop extjs"
# Sencha ExtJS
alias sencha="~/bin/Sencha/Cmd/6.5.3.6/sencha"

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


ssh-add ~/.ssh/ciss/id_rsa

cls