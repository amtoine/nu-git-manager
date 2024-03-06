# `gm repo compare` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L35))
compare the changes between two revisions, from a target to the "head"



## Parameters
- `target` <`string@get-branches`>: the target to compare from
- `--head` <`string@get-branches`> = `HEAD`: the "head" to use for the comparison


## Signatures
| input     | output   |
| --------- | -------- |
| `nothing` | `string` |
