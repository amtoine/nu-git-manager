# `gm cfg` from `nu-git-manager-sugar dotfiles` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/dotfiles.nu#L28))
manage dotfiles from anywhere

this command is basically a thin wrapper around the `git` command... but for
_bare_ dotfiles.

`gm cfg` requires the following environment variables to be defined
- `DOTFILES_GIT_DIR`: the location where to find the _bare_ repo of the
    dotfiles, e.g. `~/documents/repos/dotfiles` or something like
    `$env.GIT_REPOS_HOME | path join "github.com" "amtoine" "dotfiles"`
- `DOTFILES_WORKTREE`: the actual worktree where the dotfiles live, e.g. the
    home directory

# Examples
```nushell
# list all the files that are tracked as dotfiles
gm cfg ls-files ~
```
---
```nushell
# get the current status of the dotfiles in short format
gm status --short
```

## Parameters


## Signatures
| input | output |
| ----- | ------ |
| `any` | `any`  |
