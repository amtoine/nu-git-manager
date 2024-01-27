# `gm clean` from `nu-git-manager` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager/nu-git-manager/mod.nu#L560))
clean the store

this command will mainly remove empty directory recursively.

**/!\\** this command will return sanitized paths. **/!\\**

## Examples
```nushell
# clean the store
gm clean
```
---
```nushell
# list the leaves of the store that would have to be cleaned
gm clean --list
```

## Parameters
- `--list` <`bool`>: only list without cleaning


## Signatures
| input     | output         |
| --------- | -------------- |
| `nothing` | `list<string>` |
