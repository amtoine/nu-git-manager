# `gm repo branch list` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L75))
list local branches

> **Note**  
> in the following, a "*dangling*" branch refers to a branch that does not have any remote
> counterpart, i.e. it's a purely local branch.

## Examples
```nushell
# list branches and their associated remotes
gm repo branch list
```

## Parameters


## Signatures
| input     | output                                         |
| --------- | ---------------------------------------------- |
| `nothing` | `table<branch: string, remotes: list<string>>` |
