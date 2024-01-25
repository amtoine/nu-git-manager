# `gm repo get commit` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L24))
get the commit hash of any revision

## Examples
```nushell
# get the commit hash of the currently checked out revision
gm repo get commit
```
---
```nushell
# get the commit hash of the main branch
gm repo get commit main
```

## Parameters
- parameter_name: revision
- parameter_type: positional
- syntax_shape: string
- is_optional: true
- description: the revision to get the hash of
- parameter_default: HEAD

## Signatures
| input     | output   |
| --------- | -------- |
| `nothing` | `string` |
