# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Directory shortcuts
alias d="cd ~/Documents"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias work="cd ~/Work"
alias dev="cd ~/Dev"
alias dot="cd ~/dotfiles && code ."
alias dotfiles="cd ~/dotfiles"
alias meow="cd ~/.config/kitty && code ."

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias amend="git commit --amend --no-edit"
alias force="git push --force --no-verify"
alias stash="git stash"
alias pop="git stash pop"
alias upstream="git push -u origin HEAD"
alias rebase="git rebase origin/develop && yarn"
alias develop="git checkout develop && git fetch --all && git pull"
alias wth="git rev-parse HEAD"

# Config file shortcuts
alias zrc="code ~/dotfiles/zsh/.zshrc"
alias zshsource="source ~/.zshrc"
alias gitconfig="vim ~/.gitconfig"

# System utilities
alias myip="ipconfig getifaddr en0"
alias clean-cache="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"
alias clear='clear && printf "\033[3J"'
alias cls='clear && printf "\033[3J"'

# Package management
alias linked="ls -l node_modules | grep ^l"

# Enhanced ls with colors (using standard ls)
alias ll="ls -lh"
alias la="ls -lah"

# Safety nets
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Create parent directories on demand
alias mkdir="mkdir -pv"

# Colorize grep output
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# Get week number
alias week="date +%V"

# IP addresses
alias localip="ipconfig getifaddr en0"
alias publicip="curl -s https://api.ipify.org && echo"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"