
# Update Xcode Command Line Tools
xcode-select --install

# Check Homebrew and install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/cassiano/.zprofile

    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update homebrew recipes
brew update

brew cleanup