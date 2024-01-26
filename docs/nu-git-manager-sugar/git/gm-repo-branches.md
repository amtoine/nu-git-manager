# `gm repo branches` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L72))
inspect local branches

> **Note**  
> in the following, a "*dangling*" branch refers to a branch that does not have any remote
> counterpart, i.e. it's a purely local branch.

## Examples
```nushell
# list branches and their associated remotes
gm repo branches
```
---
```nushell
# clean all dangling branches
gm repo branches --clean
```

## Parameters
- `--clean` <`bool`>: clean all dangling branches


## Signatures
| input     | output                                         |
| --------- | ---------------------------------------------- |
| `nothing` | `table<branch: string, remotes: list<string>>` |
