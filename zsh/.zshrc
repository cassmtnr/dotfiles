export ZSH=$HOME/.oh-my-zsh

export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export JAVA_HOME=$(/usr/libexec/java_home)

export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle
export ANDROID_HOME=/Users/cassiano/Library/Android/sdk
export ANDROID_NDK_HOME=/usr/local/share/android-ndk
export INTEL_HAXM_HOME=/usr/local/Caskroom/intel-haxm
export ADB_HOME=$ANDROID_HOME/platform-tools/adb

export PATH=$ANT_HOME/bin:$PATH
export PATH=$MAVEN_HOME/bin:$PATH
export PATH=$GRADLE_HOME/bin:$PATH
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/build-tools/27.0.3:$PATH
export PATH=$ADB_HOME:$PATH

ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
    git
    node
    npm
    osx
)

source $ZSH/oh-my-zsh.sh

export UPDATE_ZSH_DAYS=1

mkd () {
    mkdir -p "$@" && cd "$@"
}

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

###########
# ALIASES #
###########

alias zrc="code ~/Dropbox/Dev/dotfiles/zsh/.zshrc"
alias dot="cd ~/Dropbox/Dev/dotfiles && code ."
alias dotfiles="cd ~/Dropbox/Dev/dotfiles"

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

### Added by Zplugin's installer
source $HOME/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

zplugin light zsh-users/zsh-autosuggestions
zplugin light zsh-users/zsh-completions
zplugin light zdharma/fast-syntax-highlighting

ssh-add ~/.ssh/github/id_rsa

clear

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /Users/cassiano/Downloads/gb-studio-master/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/cassiano/Downloads/gb-studio-master/node_modules/tabtab/.completions/electron-forge.zsh