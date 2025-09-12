# Create a directory and cd into it
mkd() {
    mkdir -p "$@" && cd "$@"
}

# Kill process running on specified port
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port>"
        return 1
    fi
    lsof -t -i tcp:"$1" | xargs kill 2>/dev/null || echo "No process found on port $1"
}

# Get weather for a location
weather() {
    curl -s "wttr.in/${1:-}" | less -R
}

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create a data URL from a file
dataurl() {
    local mimeType=$(file -b --mime-type "$1")
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8"
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Start a simple HTTP server
server() {
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    python3 -m http.server "$port"
}

# Git clone and cd into directory
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Quick backup of a file
backup() {
    if [[ -f "$1" ]]; then
        cp "$1" "${1}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backed up $1"
    else
        echo "File $1 does not exist"
    fi
}

# Find and replace in current directory
findreplace() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: findreplace <find> <replace>"
        return 1
    fi
    find . -type f -exec sed -i '' "s/$1/$2/g" {} +
}

# Claude Flow helper function
flow() {
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
        echo "  flow init <project-name>     - Initialize a new project"
        echo "  flow resume                  - Resume previous session with summary"
        echo "  flow resume dotfiles         - Resume specific dotfiles session"
        echo "  flow wizard                  - Run hive-mind wizard"
        echo ""
        echo "Examples:"
        echo "  flow init my-app"
        echo "  flow resume"
        echo "  flow resume dotfiles"
        echo "  flow wizard"
    fi
}

# Playwright install helper (for work environments with proxy)
playwright-install() {
    if [[ -z "$1" ]]; then
        echo "Usage: playwright-install <proxy-url>"
        return 1
    fi
    HTTPS_PROXY="http://$1" npx playwright install
}

# Lazy load NVM to improve shell startup time
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm "$@"
}

# Lazy load Node (via NVM)
node() {
    unset -f node
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    node "$@"
}

# Lazy load npm (via NVM)
npm() {
    unset -f npm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    npm "$@"
}

# Lazy load npx (via NVM)
npx() {
    unset -f npx
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    npx "$@"
}