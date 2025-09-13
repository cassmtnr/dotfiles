#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd)

echo "=============================="
echo "Starting MACHINE configuration"
echo "=============================="

echo "====================="
echo "Installing Oh My Zsh!"
echo "====================="

# Remove already existing Oh My Zsh! folder
rm -r ~/.oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "============================="
echo "Starting settings of dotfiles"
echo "============================="

# Backup an existing .zshrc if exists
echo "Backing up an existing .zshrc config"
if [[ -f "$HOME/.zshrc" ]]; then
    mv -v "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

ln -s -F -i "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"

echo ".zshrc file added to home"

echo "==========================="
echo "Setting configuration files"
echo "==========================="

mkdir -p "$HOME/.config"
# Find all files and directories in the source directory
find "$DOTFILES_ROOT/.config" -mindepth 1 -print | while read -r file; do
  # Determine the target path
  target="$HOME/.config/${file#$DOTFILES_ROOT/.config/}"

  # Create the parent directory for the target if it doesn't exist
  mkdir -p "$(dirname "$target")"

  # Create the symlink
  ln -s "$file" "$target"
done

sh "$DOTFILES_ROOT/homebrew/install.sh"

echo "Installing Homebrew packages from Brewfile"
brew bundle --file="$DOTFILES_ROOT/homebrew/Brewfile"

echo "Setting up Node.js environment"
if [ -f "$DOTFILES_ROOT/node/install.sh" ]; then
    sh "$DOTFILES_ROOT/node/install.sh"
fi

# Cleanup leftovers in the original folder
rm -rf "$DOTFILES_ROOT/.config/kitty/kitty"
rm -rf "$DOTFILES_ROOT/.config/gh/gh"

echo "Config files setup is done!"

echo "============================"
echo "Starting MacOS settings"
echo "============================"

# Creates a folder for Screenshots
mkdir -p "$HOME/Screenshots"

sh macos/defaults.sh

echo "MacOS settings is done!"

echo "=============================="
echo "MACHINE configuration is done!"
echo "=============================="