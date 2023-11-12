#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd)

echo "=============================="
echo "Starting MACHINE configuration"
echo "=============================="

sh "$DOTFILES_ROOT/homebrew/install.sh"
sh "$DOTFILES_ROOT/homebrew/apps.sh"

echo "============================="
echo "Installing Oh My Zsh!"
echo "============================="

# Remove already existing Oh My Zsh! folder
rm -r ~/.oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "============================="
echo "Starting settings of dotfiles"
echo "============================="

echo "Backing up an existing .zshrc config"
# Backup an existing .zshrc if any
if [[ -f "$HOME/.zshrc" ]]; then
    mv -v "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

ln -s -F -i "$DOTFILES_ROOT/zsh/.zshrc" "$HOME/.zshrc"
echo ".zshrc file added to home"


echo "============================="
echo "Starting settings MacOS configuration"
echo "============================="

# Creates a folder for screenshots
mkdir -p "$HOME/Screenshots"

sh macos/defaults.sh