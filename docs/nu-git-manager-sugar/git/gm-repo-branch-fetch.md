# `gm repo branch fetch` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L188))
fetch a remote branch locally, without pulling down the whole remote



## Parameters
- `remote` <`string@get-remotes`>: the branch to fetch
- `branch` <`string@get-branches`>: the remote to fetch the branch from
- `--strategy` <`string@get-strategies`> = `none`: the merge strategy to use


## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
