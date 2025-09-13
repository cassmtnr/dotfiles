#!/bin/bash

# Node.js and NPM setup script
# This script sets up Node.js via NVM and installs global NPM packages

set -e

echo "Setting up Node.js environment..."

# Load NVM if installed via Homebrew
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "/opt/homebrew/opt/nvm/nvm.sh"
elif [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "/usr/local/opt/nvm/nvm.sh"
fi

# Check if NVM is now available
if ! command -v nvm &> /dev/null; then
    echo "NVM not found. It may need a shell restart to be available."
    echo "Please restart your terminal and run this script again."
    echo "Or manually run: source ~/.zshrc"
    exit 0
fi

# Install Node.js LTS version
echo "Installing Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default node

# Show installed version
echo "Node.js version:"
node --version
echo "NPM version:"
npm --version

# Define global NPM packages to install
npm_packages=(
    npm
    yarn
    typescript
    eslint
    nodemon
)

# Install global NPM packages
if [ ${#npm_packages[@]} -gt 0 ]; then
    echo "Installing global NPM packages..."
    npm install -g "${npm_packages[@]}"
    echo "Global NPM packages installed:"
    npm list -g --depth=0

    # Show Yarn version if installed
    if command -v yarn &> /dev/null; then
        echo "Yarn version:"
        yarn --version
    fi
else
    echo "No packages to install"
fi

echo "Node.js setup complete!"