# TODO

## `install_homebrew` has never bootstrapped Homebrew on Linux

The last gap in phase-03's verification, narrowed from "needs a from-scratch
Linux run" on 2026-08-30.

CI runs `./install.sh` twice on ubuntu-latest and macos-latest, and on a clean
checkout it really does install apt dependencies, Oh My Zsh, the full brewfile
and Node via NVM, then passes again on the second run. `ensure_ai_repo` cloned
the private repo for real on tars. So every path is covered except one: both
runners ship Homebrew preinstalled, so `install_homebrew` reports "already
installed" and its Linux bootstrap has never executed. tars had it too.

That bootstrap is the riskiest step to leave untested — it needs sudo, a large
download, and it sets up the PATH that `.zshenv` and `ensure_brew_path` depend
on. Testing it needs a machine or container without Homebrew; tars has no
container runtime installed, and adding one is its own decision.
