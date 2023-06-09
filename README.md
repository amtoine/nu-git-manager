# nu-git-manager
A collection of Nushell tools to manage `git` repositories.

## :bulb: what is `nu-git-manager`
like [`ghq`](https://github.com/x-motemen/ghq), `nu-git-manager` aims at being a fully-featured
repository manager, purely written in Nushell.

the public API of `nu-git-manager` is greatly inspired by `ghq` for now but this might very likely change
in the future!

regarding versions, as `nu-git-manager` is tied to the version of the main `nushell/nushell` repo,
its versioning cycle will be the same
- a new minor release every 3 weeks
- starting may 2023 tuesday the 16th

more information can be found in the [documentation](docs/)!

## :link: requirements
- Nushell 0.80.1+
- `git` 2.40.1
- `gh` (optional) 2.29.0 (used by `sugar gh`)

## :recycle: installation [here](docs/installation/)

## :gear: usage
in your `config.nu` you can add the following to load `nu-git-manager` modules:
```nu
# config.nu

# load the main `gm` module
use nu-git-manager gm

# the following are non-essential modules
use nu-git-manager sugar git                # load `git` tool extensions
use nu-git-manager sugar gh                 # load commands to interact with *GitHub*
use nu-git-manager sugar gist               # load commands to interact with *GitHub* gists
use nu-git-manager sugar completions git *  # load some `git` completion
use nu-git-manager sugar dotfiles           # load tools to manage versionned dotfiles
```

then you have access to the whole `nu-git-manager` suite :partying_face:

### :pray: getting help
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

## :exclamation: some ideas of advanced (?) usage
one thing i like to do in my config to go ***BLAZZINGLY FAST*** is to use keybindings to call some `nu-git-manager` commands
in one key stroke :smirk:

- with `gm` activated, i can jump to any repo from anywhere with `<c-g>`
```nu
{
    name: open_repo
    modifier: control
    keycode: char_g
    mode: [emacs, vi_insert, vi_normal]
    event: {
        send: executehostcommand
        cmd: "gm goto"
    }
}
```
- with `sugar dotfiles` activated, i can edit any configuration file from anywhere with `<c-v>`
```nu
{
    name: edit_config
    modifier: control
    keycode: char_v
    mode: [emacs, vi_insert, vi_normal]
    event: {
        send: executehostcommand
        cmd: "dotfiles edit"
    }
}
```

## :calendar: the roadmap of `nu-git-manager`
- [ ] complete the main `gm` commands
- [ ] support more hosts, e.g. *GitLab*
- [ ] add more external completions, namely for `git` and `gh`, maybe `glab`

[nushell/nushell#9066]: https://github.com/nushell/nushell/pull/9066
[`a2a346e39`]: https://github.com/nushell/nushell/commit/a2a346e39c53e386b97d8d7f9a05ed58298e8789
[#21]: https://github.com/amtoine/nu-git-manager/pull/21
