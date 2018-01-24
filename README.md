# dotfiles.
These are my personal tweaks and dotfiles.

In this repository I save all the scripts, alias and dotfiles I use everyday on my personal computer.

## before everything
First, I am using [Homebrew](https://brew.sh/), [Homebrew Cask](https://github.com/caskroom/homebrew-cask) and [MAS](https://github.com/mas-cli/mas) to install Mac applications and command-line tools.

Secondly, this repository also includes system preferences, which you can carefully check in my [macOS defaults file](macos/defaults).

<!-- Lastly, not every file in this repository is being directly used. Some files, such as editor settings, are here for backup purposes. -->

## starting the installation
**1.** Check for software updates.
```sh
$ sudo softwareupdate -i -r
```

**2.** Get this project somehow and go to its directory. Using [Git](http://www.git-scm.com/):
```sh
$ git clone https://github.com/cassianomon/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
```

**3.** Start running the start.sh file. This will install [Homebrew](https://brew.sh/), [Homebrew Cask](https://github.com/caskroom/homebrew-cask) and [MAS](https://github.com/mas-cli/mas), then it will automatically run the installation of the [apps](homebrew/apps).

```sh
$ sh ./start.sh
```
<!--
**4.** Install dotfiles (see [brewfile](brew/brewfile)).

```sh
$ sh ./install-dotfiles
```

**5.** Tell Git who you are.
> I prefer doing it in a separate `gitlocal` file, which is included in my `gitconfig`.

```sh
$ git config -f ~/.gitlocal user.email "{Your email}"
$ git config -f ~/.gitlocal user.name "{Your name}"
```

**6.** Tell [npm](https://www.npmjs.com/) who you are.
```sh
$ npm set init.author.name "{Your name}"
$ npm set init.author.email "{Your email}"
$ npm set init.author.url "{Your URL}"
$ npm adduser
```

# thanks
We can learn a lot about productivity just exploring the way people work every day. Personally, I got highly inspired by [Holman](https://github.com/holman), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), [Deny Dias](https://github.com/denydias/dotfiles) and [this question](http://stackoverflow.com/questions/171563/whats-in-your-zshrc).

I can't agree more with [Holman](https://github.com/holman)'s thoughts on dotfiles: [dotfiles are meant to be forked](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked). -->

###### LICENSE
[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](http://creativecommons.org/publicdomain/zero/1.0/)


## Inspired by their dotfiles

[@mathiasbynens](https://github.com/mathiasbynens/dotfiles)
[@rodionovd](https://github.com/rodionovd/dotfiles)
[@diessica](https://github.com/diessica/dotfiles)
[@holman](https://github.com/holman/dotfiles)