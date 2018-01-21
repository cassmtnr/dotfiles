#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd)

echo "=================================="
echo "Installing cassiano's .dotfiles  "
echo "=================================="

sh "$DOTFILES_ROOT/install_homebrew.sh"
sh "$DOTFILES_ROOT/app_installation.sh"

#sh "$DOTFILES_ROOT/zsh/zsh.sh"
#sh "$DOTFILES_ROOT/vim/vim.sh"
#sh "$DOTFILES_ROOT/git/git.sh"
#sh "$DOTFILES_ROOT/xcode/xcode.sh"
#sh "$DOTFILES_ROOT/iterm2/iterm2.sh"

# Install my private dotfiles as well
# if [[ "$USER" == "cassiano" ]]; then
#     git clone git@github.com:rodionovd/dotfiles-private.git
#     (cd /.dotfiles-private && ./bootstrap)
# fi

# sh "$DOTFILES_ROOT/osx.sh"

# echo "============================================="
# echo "Don't forget to run ./after_xcode_install.sh "
# echo "when you install Xcode                     :)"
# echo "============================================="