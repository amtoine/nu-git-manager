# nu-git-manager
A collection of Nushell tools to manage `git` repositories.

# Table of content
- [:bulb: what is `nu-git-manager`](#bulb-what-is-nu-git-manager-toc)
- [:link: requirements](#link-requirements-toc)
- [:recycle: installation](#recycle-installation-toc)
- [:gear: usage](#gear-usage-toc)
- [:pray: getting help](#pray-getting-help-toc)
- [:exclamation: some ideas of advanced (?) usage](#exclamation-some-ideas-of-advanced--usage-toc)

## :bulb: what is `nu-git-manager` [[toc](#table-of-content)]
like [`ghq`](https://github.com/x-motemen/ghq), `nu-git-manager` aims at being a fully-featured
repository manager, purely written in Nushell.

it provides two main modules:
- `nu-git-manager` itself which ships the main `gm` command
- `nu-git-manager sugar` which exports a bunch of Git-related tools, e.g. to help use the `gh` command or augment the capabilities of `git`

## :link: requirements [[toc](#table-of-content)]
- [Nushell] 0.89.0
    - with Cargo and `cargo install nu`
- `git` 2.34.1
    - with Pacman and `pacman -S extra/git`
    - with Nix and `nix run nixpkgs#git`
- `gh` (optional) 2.29.0 (used by `sugar gh`)
    - with Pacman and `pacman -S community/github-cli`
    - with Nix and `nix run nixpkgs#gh`

## :recycle: installation [[toc](#table-of-content)]
- install [Nupm] (**recommended**) by following the [Nupm instructions]
- download the `nu-git-manager` repository
```shell
git clone https://github.com/amtoine/nu-git-manager
```
- activate the `toolkit` module with `use toolkit.nu`
- install the `nu-git-manager` and `nu-git-manager-sugar` packages
```nushell
toolkit install
```
- verify the installation after restarting Nushell
```nushell
gm version
```

> **Note**
> if you are using the latest stable release of Nushell, then you should install `nu-git-manager`
> from the `main` branch, i.e. by default.
>
> if you want to use the latest and hotest builds of Nushell, either by building from source yourself
> or using the [nightly builds](https://github.com/nushell/nightly), you might want to _checkout_
> the [`nightly`](https://github.com/amtoine/nu-git-manager/tree/nightly) branch and install from
> there.
> this alternative branch should contain all fixes and newest features from the latest versions of
> Nushell :fire:

## :gear: usage [[toc](#table-of-content)]
in your `config.nu` you can add the following to load `nu-git-manager` modules:
```nushell
# load the main `gm` command
use nu-git-manager *

# the following are non-essential modules
use nu-git-manager-sugar extra *              # augment `gm` with additional commands
```

> **Note**  
> please have a look at the [documentation of NGM](./docs/index.md) for more modules and commands

then you have access to the whole `nu-git-manager` suite :partying_face:

### :pray: getting help [[toc](#table-of-content)]
please have a look at the [documentation of NGM](./docs/index.md)

## :exclamation: some ideas of advanced (?) usage [[toc](#table-of-content)]
everytime i open a terminal, i use [Tmux] to manage sessions, switch between them, detach and reattach, quite a ***BLAZZINGLY FAST*** workflow for my taste :smirk:

to achieve this, i use the [`tmux-sessionizer.nu` script][`tmux-sessionizer.nu`], again installed with [Nupm] :ok_hand:

then, in my Tmux config, i have a binding to
1. list all my Git repositories
2. fuzzy-pick one of them with the [`main` command of `tmux-sessionizer.nu`][`tmux-sessionizer.nu`]
3. create or reattach to the session associated with the repository
```bash
# ~/.config/tmux/tmux.conf

NUPM_HOME="~/.local/share/nupm"
TMUX_SESSIONIZER="$NUPM_HOME/scripts/tmux-sessionizer.nu"

bind-key -r t display-popup -E "nu --commands '
    use $NUPM_HOME/modules/nu-git-manager *;\
    $TMUX_SESSIONIZER (gm list --full-path) --short\
'"
```

[Nushell]: https://github.com/nushell/nushell

[Nupm]: https://github.com/nushell/nupm
[Nupm instructions]: https://github.com/nushell/nupm#-installation

[Tmux]: https://github.com/tmux/tmux
[`tmux-sessionizer.nu`]: https://github.com/amtoine/tmux-sessionizer
