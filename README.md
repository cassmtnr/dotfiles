# Dotfiles

Modern, secure, and performant dotfiles configuration for MacOS.

## Quick Start

```bash
# Clone and install
git clone https://github.com/cassmtnr/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Customization

### Required Customizations

#### 1. SSH Configuration

The SSH config is automatically symlinked to `~/.ssh/config`. Edit it directly:

```bash
vim ~/dotfiles/ssh/config
```

Update the configuration with:

- SSH key paths (replace generic paths with your actual key locations)
- Host configurations for your Git providers
- Any specific connection settings

Generate SSH keys if needed:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

#### 2. Git Configuration

Update git configuration with your details:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 3. SSH Agent Configuration

Edit `zsh/ssh-agent.zsh` and update the `ssh_keys` array with your actual SSH key paths:

```bash
local ssh_keys=(
    "$HOME/.ssh/github/id_ed25519"  # GitHub key
    "$HOME/.ssh/personal/id_ed25519"   # Personal key (if exists)
    "$HOME/.ssh/id_rsa"              # Legacy RSA key (if exists)
)
```

#### 4. Machine-Specific Settings

Create a local configuration file for machine-specific settings:

```bash
touch ~/.zshrc.local
```

Add any local customizations like:

- Environment variables
- Local aliases
- Machine-specific paths
- Private configurations

#### 5. Package Customization

Review and customize the package lists:

- `homebrew/Brewfile` - All Homebrew packages and applications
- `node/install.sh` - Node.js setup with essential development packages

### Additional Customizations

#### Adding Aliases

Edit `~/dotfiles/zsh/aliases.zsh` to add custom aliases.

#### Adding Functions

Edit `~/dotfiles/zsh/functions.zsh` to add custom functions.

#### Changing the Theme

1. For Oh My Zsh themes, edit the `ZSH_THEME` variable in `.zshrc`
2. For Starship customization, edit `~/dotfiles/config/starship.toml`

#### Adding Homebrew Packages

Edit `~/dotfiles/homebrew/Brewfile` and run:

```bash
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

## Security Notes

- Never commit actual SSH keys or sensitive data
- Use `.zshrc.local` for private configurations
- The `.gitignore` is configured to exclude sensitive files
- SSH key paths in templates are examples - replace with your actual paths

## Pro Tips

1. Fork this repository to your own GitHub account
2. Clone your fork and make personal customizations
3. Keep your fork private if it contains sensitive information
4. Regularly sync with the upstream repository for updates

## Available Aliases & Functions

This dotfiles configuration includes a comprehensive set of aliases and functions to improve your terminal productivity.

**Source files:**

- Aliases: [`zsh/aliases.zsh`](zsh/aliases.zsh)
- Functions: [`zsh/functions.zsh`](zsh/functions.zsh)

### Aliases Reference

#### Navigation

- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `.....` - Go up four directories

#### Directory Shortcuts

- `d` - Go to Documents
- `dl` - Go to Downloads
- `dt` - Go to Desktop
- `work` - Go to Work folder
- `dev` - Go to Dev folder
- `dot` - Go to dotfiles and open in VS Code
- `dotfiles` - Go to dotfiles
- `meow` - Go to Kitty config and open in VS Code

#### Git Shortcuts

- `gl` - Pretty git log with graph: `git log --oneline --graph --decorate`
- `amend` - Amend last commit without editing message
- `force` - Force push with safety flag
- `upstream` - Push and set upstream to current branch
- `rebase` - Rebase on develop branch and run yarn
- `develop` - Switch to develop, fetch and pull latest changes
- `wth` - Show current commit hash

#### Configuration Shortcuts

- `zrc` - Edit .zshrc in VS Code
- `zshsource` - Reload .zshrc configuration

#### System Utilities

- `publicip` - Get your public IP address
- `clean-cache` - Flush DNS cache on macOS
- `chromekill` - Kill Chrome renderer processes
- `show` - Show hidden files in Finder
- `hide` - Hide hidden files in Finder
- `week` - Get current week number

#### Development Tools

- `linked` - Show symlinked node modules

### Functions Reference

#### Directory & Navigation

- **`mkd <directory>`** - Create directory and change into it
  ```bash
  mkd new-project  # Creates 'new-project' and cd into it
  ```

#### Development Tools

- **`killport <port>`** - Kill process running on specified port
  ```bash
  killport 3000    # Kills process on port 3000
  ```

#### File Operations

- **`extract <file>`** - Extract various archive formats
  ```bash
  extract archive.zip     # Extracts zip file
  extract backup.tar.gz   # Extracts tar.gz file
  ```
  Supports: `.tar.bz2`, `.tar.gz`, `.bz2`, `.rar`, `.gz`, `.tar`, `.tbz2`, `.tgz`, `.zip`, `.Z`, `.7z`

#### Information & Utilities

- **`weather [location]`** - Get weather information
  ```bash
  weather          # Weather for your location
  weather London   # Weather for London
  ```

#### Claude Flow Integration

- **`flow <command>`** - Claude Flow helper function
  ```bash
  flow create my-app           # Initialize new project
  flow resume               # Resume previous session
  flow resume dotfiles      # Resume specific dotfiles session
  flow wizard              # Run hive-mind wizard
  ```

#### Development Environment

- **`playwright-install <proxy>`** - Install Playwright with proxy
  ```bash
  playwright-install proxy.company.com:8080
  ```

#### Performance Optimized (Lazy Loading)

- **`nvm`** - Node Version Manager (lazy loaded)
- **`node`** - Node.js (lazy loaded via NVM)
- **`npm`** - NPM (lazy loaded via NVM)
- **`npx`** - NPX (lazy loaded via NVM)

These functions automatically load NVM only when first used, improving shell startup time.

## License

These dotfiles are released under the CC0 1.0 Universal license.

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

## Inspired by

[@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
[@rodionovd](https://github.com/rodionovd/dotfiles)
[@diessica](https://github.com/diessica/dotfiles)
[@holman](https://github.com/holman/dotfiles)
