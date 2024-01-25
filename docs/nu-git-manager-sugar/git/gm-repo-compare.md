# `gm repo compare` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L31))
compare the changes between two revisions, from a target to the "head"



## Parameters
- parameter_name: target
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the target to compare from
---
- parameter_name: head
- parameter_type: named
- syntax_shape: string
- is_optional: true
- description: the "head" to use for the comparison
- parameter_default: HEAD

## Signatures
| input     | output   |
| --------- | -------- |
| `nothing` | `string` |
