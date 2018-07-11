#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd)

echo "=============================="
echo "Starting MACHINE configuration"
echo "=============================="

sh "$DOTFILES_ROOT/homebrew/install.sh"
sh "$DOTFILES_ROOT/homebrew/apps.sh"

# Install my private dotfiles as well
# if [[ "$USER" == "cassiano" ]]; then
#     git clone git@github.com:cassianomon/dotfiles-private.git
#     (cd /.dotfiles-private && ./bootstrap)
# fi

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


echo "Backing up an existing .hyper.js config"
# Backup an existing .hyper.js if any
if [[ -f "$HOME/.hyper.js" ]]; then
    mv -v "$HOME/.hyper.js" "$HOME/.hyper.js.bak"
fi

ln -s -F -i "$DOTFILES_ROOT/hyper/.hyper.js" "$HOME/.hyper.js"
echo ".hyper.js file added to home"






