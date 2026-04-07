# ===============================================
# .zshrc - Interactive shell configuration
# ===============================================

# Performance profiling (uncomment to debug slow startup)
# zmodload zsh/zprof

# Oh My Zsh configuration (must come before sourcing oh-my-zsh)
ZSH_THEME=""  # Disabled — Starship handles the prompt
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

# Source modular configuration files
DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/dotfiles}"

# Set up completion paths BEFORE Oh My Zsh (which calls compinit internally).
# fpath entries must be in place before compinit scans them.
fpath=(
    $HOME/.zsh/completions(N)
    $HOME/.docker/completions(N)
    $fpath
)
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    fpath=(
        $HOMEBREW_PREFIX/share/zsh/site-functions(N)
        $HOMEBREW_PREFIX/share/zsh-completions(N)
        $fpath
    )
fi

# Source Oh My Zsh (handles compinit with all fpath entries above)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Load configuration modules
[[ -f "$DOTFILES_ROOT/.completion" ]] && source "$DOTFILES_ROOT/.completion"
[[ -f "$DOTFILES_ROOT/.aliases" ]] && source "$DOTFILES_ROOT/.aliases"
[[ -f "$DOTFILES_ROOT/.functions" ]] && source "$DOTFILES_ROOT/.functions"
[[ -f "$DOTFILES_ROOT/.ssh-agent" ]] && source "$DOTFILES_ROOT/.ssh-agent"
[[ -f "$DOTFILES_ROOT/.bun" ]] && source "$DOTFILES_ROOT/.bun"

# Load Homebrew shell integrations
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    # Zsh autosuggestions
    [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

    # Zsh syntax highlighting (load last among plugins)
    [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Starship prompt (if installed)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Load NVM (Node Version Manager)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -n "$HOMEBREW_PREFIX" && -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
    source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
fi

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

# Claude Code wrapper — reset kitty keyboard protocol on exit
# Prevents leftover escape sequences (e.g. '9;5u' on Ctrl+C)
claude() {
    command claude "$@"
    printf '\e[>0u'
}

# Fix bracketed paste issues
# This resolves problems with extra characters when pasting
if [[ $TERM != "dumb" ]]; then
    # Properly handle bracketed paste mode
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
    zstyle ':bracketed-paste-magic' active-widgets '.self-*'
else
    # Disable bracketed paste for dumb terminals
    unset zle_bracketed_paste
fi

# Python (version matches .brewfile)
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/python@3.13/libexec/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/opt/python@3.13/libexec/bin:$PATH"
fi

# Deduplicate PATH entries
typeset -U path

# Performance profiling (uncomment to see results)
# zprof
