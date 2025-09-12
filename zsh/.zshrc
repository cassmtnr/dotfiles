# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi
export ZSH=$HOME/.oh-my-zsh


plugins=(
  git
)

source $(brew --prefix)/share/zsh-completions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

export NODE_OPTIONS="--max-old-space-size=8192"

# Loads NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

nvm use v20.19.2

# ZSH
ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX="true"
UPDATE_ZSH_DAYS=30
DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

# load zsh-completions
autoload -U compinit && compinit


# ###########
# FUNCTIONS #
# ###########

mkd () {
    mkdir -p "$@" && cd "$@"
}

killport () {
    lsof -t -i tcp:"$@" | xargs kill
}

# Exclusive for WORK machine:
playwright-install () {
    HTTPS_PROXY=http://"$@" npx playwright install
}

weather () {
    curl wttr.in/"$@"
}

flow () {
    cd ~/Dev
    if [[ "$1" == "init" ]] && [[ -n "$2" ]]; then
        npx claude-flow init --force --project-name="$2"
    elif [[ "$1" == "resume" ]]; then
        if [[ "$2" == "dotfiles" ]]; then
            npx claude-flow hive-mind resume session-1757710180784-9lvy5ayjp --claude
        else
            npx claude-flow swarm "Resume the previous sessions of implementations and give me a summary of what was done and what needs to be done" --continue-session
        fi
    elif [[ "$1" == "wizard" ]]; then
        npx claude-flow hive-mind wizard
    else
        echo "Usage:"
        echo "  claude-flow init <project-name>     - Initialize a new project"
        echo "  claude-flow resume                   - Resume previous session with summary"
        echo "  claude-flow resume dotfiles          - Resume specific dotfiles session"
        echo "  claude-flow wizard                   - Run hive-mind wizard"
        echo ""
        echo "Examples:"
        echo "  claude-flow init my-app"
        echo "  claude-flow resume"
        echo "  claude-flow resume dotfiles"
        echo "  claude-flow wizard"
    fi
}

# ###########
# # ALIASES #
# ###########

alias zrc="code ~/dotfiles/zsh/.zshrc"
alias dot="cd ~/dotfiles && code ."
alias meow="cd ~/.config/kitty && code ."
alias dotfiles="cd ~/dotfiles"
alias myip="ipconfig getifaddr en0"
alias zshsource="source ~/.zshrc"
alias gitconfig="vim ~/.gitconfig"
alias wth="git rev-parse HEAD"
alias clean-cache="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"



# # Kill all the tabs in Chrome to free up memory
# # [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"


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

alias amend="git commit --amend --no-edit"
alias clear='clear && printf "\033[3J"'
alias cls='clear && printf "\033[3J"'
alias develop="git checkout develop && git fetch --all && git pull"
alias force="git push --force --no-verify"
alias stash="git stash"
alias pop="git stash pop"
alias upstream="git push -u origin HEAD"
alias rebase="git rebase origin/develop && yarn"
alias linked="ls -l node_modules | grep ^l"

# SSH agent management is handled by ssh-agent.zsh module

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

source $ZSH/oh-my-zsh.sh

[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

clear

# Docker CLI completions
[[ -d "$HOME/.docker/completions" ]] && fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
