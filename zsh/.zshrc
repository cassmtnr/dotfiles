export ZSH=$HOME/.oh-my-zsh

plugins=(
  git
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
)


export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export NODE_OPTIONS="--max-old-space-size=8192"

# Exclusive for WORK machine:
# export NODE_EXTRA_CA_CERTS="$HOME/RootCA_01.pem"

# Loads NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

nvm use v18.7.0


# ZSH
ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX="true"
UPDATE_ZSH_DAYS=30
DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

# load zsh-completions
autoload -U compinit && compinit


mkd () {
    mkdir -p "$@" && cd "$@"
}

killport () {
    lsof -t -i tcp:"$@" | xargs kill
}

playwright-install () {
    HTTPS_PROXY=http://"$@" npx playwright install
}

weather () {
    curl wttr.in/"$@"
}

# ###########
# # ALIASES #
# ###########

alias zrc="code ~/dotfiles/zsh/.zshrc"
alias dot="cd ~/dotfiles && code ."
alias dotfiles="cd ~/dotfiles"
alias myip="ipconfig getifaddr en0"
alias zshsource="source ~/.zshrc"
alias gitconfig="vim ~/.gitconfig"

# type sublime . to open current folder in Sublime Text
alias sublime="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl --new-window $@"

# # Easier navigation: .., ..., ...., .....

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# # Shortcuts

alias d="cd ~/Documents"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias work="cd ~/Work"
alias dev="cd ~/Dev"

# Exclusive for WORK machine:
# alias banking="cd ~/Work/web-banking"
# alias review="cd ~/Work/web-banking-review"
# alias tovite="cd ~/Work/web-banking-vite"
# alias proxy="cd ~/Work/package-web-proxy"
# alias linkls="( ls -l node_modules ; ls -l node_modules/@* ) | grep ^l"

alias amend="git commit --amend --no-edit"
alias cls="clear"
alias develop="git checkout develop && git fetch --all && git pull"
alias force="git push --force --no-verify"
alias pop="git stash pop"
alias push-force="git push --force-with-lease --no-verify"
alias stash="git stash"
alias status="git status"
alias upstream="git push -u origin HEAD"


# # Kill all the tabs in Chrome to free up memory
# # [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

eval $(ssh-agent)
ssh-add ~/.ssh/dev/github
# Exclusive for WORK machine:
# ssh-add ~/.ssh/work/gitlab

[[ -s "/Users/cassiano/.gvm/scripts/gvm" ]] && source "/Users/cassiano/.gvm/scripts/gvm"

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

clear

