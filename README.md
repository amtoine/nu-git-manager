# nu-git-manager
A collection of Nushell tools to manage `git` repositories.

# Table of content
- [*what is `nu-git-manager`*](#bulb-what-is-nu-git-manager-toc)
- [*requirements*](#link-requirements-toc)
- [*installation*](#recycle-installation-toc)
- [*usage*](#gear-usage-toc)
    - [*getting help*](#pray-getting-help-toc)
- [*some ideas of advanced (?) usage*](#exclamation-some-ideas-of-advanced--usage-toc)

## :bulb: what is `nu-git-manager` [[toc](#table-of-content)]
like [`ghq`](https://github.com/x-motemen/ghq), `nu-git-manager` aims at being a fully-featured
repository manager, purely written in Nushell.

it provides two main modules:
- `nu-git-manager` itself which ships the main `gm` command
- `nu-git-manager sugar` which exports a bunch of Git-related tools, e.g. to help use the `gh` command or augment the capabilities of `git`

## :link: requirements [[toc](#table-of-content)]
- [Nushell] 0.85.1+
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
- activate the `nupm` module with `use nupm`
- install the `nu-git-manager` package
```nushell
nupm install --path --force nu-git-manager
```

## :gear: usage [[toc](#table-of-content)]
in your `config.nu` you can add the following to load `nu-git-manager` modules:
```nu
# config.nu

# load the main `gm` command
use nu-git-manager [gm, "gm clone", "gm cache", "gm list", "gm root", "gm remove"]

# the following are non-essential modules
use nu-git-manager sugar git                # augmnet Git with custom commands
use nu-git-manager sugar gh                 # load commands to interact with *GitHub*
use nu-git-manager sugar gist               # load commands to interact with *GitHub* gists
```

then you have access to the whole `nu-git-manager` suite :partying_face:

### :pray: getting help [[toc](#table-of-content)]
do not hesitate to run one of the following to have more information about what `nu-git-manager` has to offer :thumbsup:
```nu
help gm
# or
gm
```
```nu
help modules git
```
```nu
help modules gh
```
```nu
help modules gist
# or
gist
```

## :exclamation: some ideas of advanced (?) usage [[toc](#table-of-content)]
everytime i open a terminal, i use [Tmux] to manage sessions, switch between them, detach and reattach, quite a ***BLAZZINGLY FAST*** workflow for my taste :smirk:

to achieve this, i use the [`tmux-sessionizer.nu` script][`tmux-sessionizer.nu`] from the [`nu-goat-scripts` package][`nu-goat-scripts`], again installed with [Nupm] :ok_hand:

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
[`tmux-sessionizer.nu`]: https://github.com/goatfiles/scripts/blob/main/nu_scripts/scripts/tmux-sessionizer.nu#L463
[`nu-goat-scripts`]: https://github.com/goatfiles/scripts/blob/main/nu_scripts/README.md#nu_scripts
