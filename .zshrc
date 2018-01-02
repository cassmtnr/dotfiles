export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"

plugins=(
  git,
  node,
  npm,
  osx
)

source $ZSH/oh-my-zsh.sh

export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export UPDATE_ZSH_DAYS=1

function mkd() {
    mkdir -p "$@" && cd "$@"
}

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

###########
# ALIASES #
###########

alias zrc="code ~/.zshrc"

# Easier navigation: .., ..., ...., .....

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Shortcuts
alias d="cd ~/Documents/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dev="cd ~/Dropbox/Dev"
alias g="git"

alias zrc="code ~/.zshrc"

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