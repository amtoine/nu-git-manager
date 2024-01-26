# `gm remove` from `nu-git-manager` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager/nu-git-manager/mod.nu#L354))
remove one of the repositories from your local store

## Examples
```nushell
# remove any repository by fuzzy-finding the whole store
gm remove --fuzzy
```
---
```nushell
# restrict the search to any one of my repositories
gm remove amtoine
```
---
```nushell
# remove a precise repo by giving its full name, a name collision is unlikely
gm remove amtoine/nu-git-manager
```
---
```nushell
# remove a precise repo without confirmation
gm remove amtoine/nu-git-manager --no-confirm
```

## Parameters
- `pattern?` <`string`>: a pattern to restrict the choices
- `--fuzzy` <`bool`>: remove after fuzzy-finding the repo(s) to clean
- `--no-confirm` <`bool`>: do not ask for confirmation: useful in scripts but requires a single match


## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
