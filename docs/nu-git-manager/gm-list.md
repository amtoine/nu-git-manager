# `gm list` from `nu-git-manager` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager/nu-git-manager/mod.nu#L230))
list all the local repositories in your local store

**/!\\** this command will return sanitized paths. **/!\\**

## Examples
```nushell
# list all the repositories in the store
gm list
```
---
```nushell
# list all the repositories in the store with their full paths
gm list --full-path
```
---
```nushell
# jump to a directory in the store
cd (gm list --full-path | input list)
```

## Parameters
- `--full-path` <`bool`>: show the full path instead of only the "owner + group + repo" name


## Signatures
| input     | output         |
| --------- | -------------- |
| `nothing` | `list<string>` |
