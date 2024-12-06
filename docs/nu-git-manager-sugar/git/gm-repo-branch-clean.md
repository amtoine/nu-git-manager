# `gm repo branch clean` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L105))
clean local dangling branches

> **Note**  
> in the following, a "*dangling*" branch refers to a branch that does not have any remote
> counterpart, i.e. it's a purely local branch.

## Examples
```nushell
# clean all dangling branches
gm repo branch clean
```

## Parameters


## Signatures
| input     | output                                  |
| --------- | --------------------------------------- |
| `nothing` | `table<name: string, revision: string>` |
