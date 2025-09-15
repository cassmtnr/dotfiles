# ===============================================
# .zshrc - Interactive shell configuration
# ===============================================

# Performance profiling (uncomment to debug slow startup)
# zmodload zsh/zprof

# Oh My Zsh configuration (must come before sourcing oh-my-zsh)
ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX="true"
UPDATE_ZSH_DAYS=30
DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"  # Speed up git status in large repos

# Oh My Zsh plugins (minimal for better performance)
plugins=(
    git
    docker-compose
    kubectl
)

# Source Oh My Zsh
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Source modular configuration files
DOTFILES_ZSH="${DOTFILES_ROOT:-$HOME/dotfiles}/zsh"

# Load configuration modules
[[ -f "$DOTFILES_ZSH/completion.zsh" ]] && source "$DOTFILES_ZSH/completion.zsh"
[[ -f "$DOTFILES_ZSH/aliases.zsh" ]] && source "$DOTFILES_ZSH/aliases.zsh"
[[ -f "$DOTFILES_ZSH/functions.zsh" ]] && source "$DOTFILES_ZSH/functions.zsh"
[[ -f "$DOTFILES_ZSH/ssh-agent.zsh" ]] && source "$DOTFILES_ZSH/ssh-agent.zsh"

# Load Homebrew shell integrations
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    # Zsh completions
    [[ -f "$HOMEBREW_PREFIX/share/zsh-completions" ]] && fpath=($HOMEBREW_PREFIX/share/zsh-completions $fpath)
    
    # Zsh autosuggestions
    [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    
    # Zsh syntax highlighting (load last)
    [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Starship prompt (if installed, replaces Oh My Zsh theme)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Load GVM (Go Version Manager)
[[ -s "$GVM_DIR/scripts/gvm" ]] && source "$GVM_DIR/scripts/gvm"

# Load Deno
[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

# Load local/private configuration (not tracked in git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_VERIFY               # Do not execute immediately upon history expansion

# Key bindings
bindkey -e  # Use emacs key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Performance profiling (uncomment to see results)
# zprof

# Clear the terminal
clear