# `gm repo remote list` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L179))
get the list of all the remotes in the current repository

## Examples
```nushell
# list all the remotes in a default `nu-git-manager` repo
gm repo remote list
```
```
#┬remote┬──────────────────fetch──────────────────┬─────────────────push──────────────────
0│origin│https://github.com/amtoine/nu-git-manager│ssh://github.com/amtoine/nu-git-manager
─┴──────┴─────────────────────────────────────────┴───────────────────────────────────────
```

## Parameters


## Signatures
| input     | output                                               |
| --------- | ---------------------------------------------------- |
| `nothing` | `table<remote: string, fetch: string, push: string>` |
