# SSH Agent Management
# Secure and efficient SSH key handling

# Function to start ssh-agent if not running
start_ssh_agent() {
    local ssh_env="$HOME/.ssh/agent.env"
    
    # Source existing agent environment if it exists
    if [[ -f "$ssh_env" ]]; then
        source "$ssh_env" > /dev/null
    fi
    
    # Check if agent is running
    if ! ssh-add -l &>/dev/null; then
        # Start new agent
        echo "Starting new SSH agent..."
        ssh-agent > "$ssh_env"
        chmod 600 "$ssh_env"
        source "$ssh_env" > /dev/null
        
        # Add keys if they exist
        add_ssh_keys
    fi
}

# Function to add SSH keys
add_ssh_keys() {
    local keys_added=0
    
    # Define your SSH keys here
    local ssh_keys=(
        "$HOME/.ssh/dev/github"
        "$HOME/.ssh/work/gitlab"
        "$HOME/.ssh/id_ed25519"
        "$HOME/.ssh/id_rsa"
    )
    
    for key in "${ssh_keys[@]}"; do
        if [[ -f "$key" ]]; then
            ssh-add -q "$key" 2>/dev/null && ((keys_added++))
        fi
    done
    
    if [[ $keys_added -gt 0 ]]; then
        echo "Added $keys_added SSH key(s) to agent"
    fi
}

# Use keychain if available (more secure than plain ssh-agent)
if command -v keychain &> /dev/null; then
    # Keychain manages ssh-agent and gpg-agent
    eval $(keychain --eval --agents ssh --inherit any --quiet)
    
    # Add specific keys
    keychain --quiet \
        ~/.ssh/dev/github \
        ~/.ssh/work/gitlab \
        ~/.ssh/id_ed25519 \
        2>/dev/null
else
    # Fall back to standard ssh-agent
    start_ssh_agent
fi

# Alias to list loaded SSH keys
alias ssh-list="ssh-add -l"

# Alias to reload SSH keys
alias ssh-reload="ssh-add -D && add_ssh_keys"