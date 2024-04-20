# `gm repo is-ancestor` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L152))
return true iif the first revision is an ancestor of the second

## Examples
```nushell
# HEAD~20 is an ancestor of HEAD
gm repo is-ancestor HEAD~20 HEAD
```
```
true
```
---
```nushell
# HEAD is never an ancestor of HEAD~20
gm repo is-ancestor HEAD HEAD~20
```
```
false
```

## Parameters
- `a` <`string`>: the base commit-ish revision
- `b` <`string`>: the *head* commit-ish revision


## Signatures
| input     | output |
| --------- | ------ |
| `nothing` | `bool` |
