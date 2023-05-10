# nu-git-manager
A collection of Nushell tools to manage `git` repositories.

## installation
> **Warning**
> `gm` requires the use of `nushell` after [nushell/nushell#9066]
> e.g. from any branch / commit based on [`a2a346e39`].
>
> alternatively, you can use any revision of `nu-git-manager`
> before [#21].

one way to install `nu-git-manager` right now is the following
- clone the repo to a location you want it to be
```nu
# env.nu
let-env NU_LIB_PATH = "/path/to/libs"
```
```nu
git clone https://github.com/amtoine/nu-git-manager.git ($env.NU_LIB_PATH | path join "nu-git-manager")
```
- make it loadable in your `NU_LIB_DIRS`
```nu
let-env NU_LIB_DIRS = ($env.NU_LIB_DIRS | append $env.NU_LIB_PATH)
```
- update it sometimes to have the latest
```nu
git -C ($env.NU_LIB_PATH | path join "nu-git-manager") pull
```

## usage
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

then you have access to the whole `nu-git-manager` suite :partying:

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

## some ideas of advanced (?) usage
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

[nushell/nushell#9066]: https://github.com/nushell/nushell/pull/9066
[`a2a346e39`]: https://github.com/nushell/nushell/commit/a2a346e39c53e386b97d8d7f9a05ed58298e8789
[#21]: https://github.com/amtoine/nu-git-manager/pull/21
