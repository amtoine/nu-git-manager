# `gm clone` from `nu-git-manager` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager/nu-git-manager/mod.nu#L88))
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
- parameter_name: url
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the URL to the repository to clone, supports HTTPS and SSH links, as well as references ending in `.git` or starting with `git@`
---
- parameter_name: remote
- parameter_type: named
- syntax_shape: string
- is_optional: true
- description: the name of the remote to setup
- parameter_default: origin
---
- parameter_name: ssh
- parameter_type: switch
- is_optional: true
- description: setup the remote to use the SSH protocol both to FETCH and to PUSH
---
- parameter_name: fetch
- parameter_type: named
- syntax_shape: completable<string>
- is_optional: true
- description: setup the FETCH protocol explicitely, will overwrite `--ssh` for FETCH
- custom_completion: git-protocols
---
- parameter_name: push
- parameter_type: named
- syntax_shape: completable<string>
- is_optional: true
- description: setup the PUSH protocol explicitely, will overwrite `--ssh` for PUSH
- custom_completion: git-protocols
---
- parameter_name: bare
- parameter_type: switch
- is_optional: true
- description: clone the repository as a "bare" project
---
- parameter_name: depth
- parameter_type: named
- syntax_shape: int
- is_optional: true
- description: the depth at which to clone the repository

## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
