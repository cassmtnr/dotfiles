export ZSH=$HOME/.oh-my-zsh

export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
    git
    node
    npm
    macos
)

ZSH_DISABLE_COMPFIX="true"
UPDATE_ZSH_DAYS=30
DISABLE_AUTO_UPDATE="true"

source $ZSH/oh-my-zsh.sh

mkd () {
    mkdir -p "$@" && cd "$@"
}

killport () {
    lsof -t -i tcp:"$@" | xargs kill
}

playwright-install () {
    HTTPS_PROXY=http://"$@" npx playwright install
}

# Pegar do zscaler

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
alias work="cd ~/Work"
alias dev="cd ~/Dev"

alias banking="cd ~/Work/banking"

alias g="git"
alias stash="git stash"
alias pop="git stash pop"
alias status="git status"
alias develop="git checkout develop && git fetch --all && git pull"
alias push-no-verify="git push --force-with-lease --no-verify"

alias n="npm"
alias y="yarn"
alias start="yarn dev"
alias rm-node="rm -rf node_modules && rm -rf package-lock.json && rm -rf yarn.lock"
alias reinstall="rm-node && yarn"

alias ip="netstat -rn | grep default"
alias sshq="code ~/.ssh"
alias ip="ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}'"

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
ssh-add ~/.ssh/dev/github
ssh-add ~/.ssh/work/gitlab


# Loads NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

nvm use v16.13.1

clear
