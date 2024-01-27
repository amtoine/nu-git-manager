# `gm clone` from `nu-git-manager` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager/nu-git-manager/mod.nu#L96))
clone a remote Git repository into your local store

will give a nice error if the repository is already in the local store.

## Examples
```nushell
# clone a repository in the local store of `nu-git-manager`
gm clone https://github.com/amtoine/nu-git-manager
```
---
```nushell
# clone as a bare repository, i.e. a repo without a worktree
gm clone --bare https://github.com/amtoine/nu-git-manager
```
---
```nushell
# clone a repo and change the name of the remote
gm clone --remote default https://github.com/amtoine/nu-git-manager
```
---
```nushell
# setup a public repo in the local store and use HTTP to fetch without PAT and push with SSH
gm clone https://github.com/amtoine/nu-git-manager --fetch https --push ssh
```
---
```nushell
# clone a big repo as a single commit, avoiding all intermediate Git deltas
gm clone https://github.com/neovim/neovim --depth 1
```

## Parameters
- `url` <`string`>: the URL to the repository to clone, supports HTTPS and SSH links, as well as references ending in `.git` or starting with `git@`
- `--remote` <`string`> = `origin`: the name of the remote to setup
- `--ssh` <`bool`>: setup the remote to use the SSH protocol both to FETCH and to PUSH
- `--fetch` <`string@git-protocols`>: setup the FETCH protocol explicitely, will overwrite `--ssh` for FETCH
- `--push` <`string@git-protocols`>: setup the PUSH protocol explicitely, will overwrite `--ssh` for PUSH
- `--bare` <`bool`>: clone the repository as a "bare" project
- `--depth` <`int`>: the depth at which to clone the repository


## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
