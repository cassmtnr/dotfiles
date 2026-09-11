# TODO

## The bare-container CI job has never run

Narrowed 2026-09-09 from "install_homebrew has never bootstrapped Homebrew on
Linux", which had been open since 2026-08-30.

Both hosted runners ship Homebrew preinstalled, so `install_homebrew` always
reported "already installed" and its Linux bootstrap — the sudo, the download,
and the PATH it leaves for `.zshenv` and `ensure_brew_path` — never executed.
The `install-without-homebrew` job in `.github/workflows/ci.yml` closes that:
`ubuntu:24.04` with no Homebrew, an unprivileged user, an assertion that brew
really is absent before `./install.sh` runs, and `ensure_brew_path` checked
afterwards.

What is left is the run itself. The job was written and its YAML validated
locally, but nothing here can execute a GitHub Actions container, so it has
never gone green. Watch the first push for the usual container-job failures:
`actions/checkout` needing more than `git`, `install_deps` assuming a package
the minimal image lacks, and the 45-minute timeout against a from-source build.
Delete this entry once it passes once.
