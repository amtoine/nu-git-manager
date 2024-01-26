# `gm repo ls` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L270))
get some information about a repo



## Parameters
- `repo?` <`path`>: the path to the repo (defaults to `.`)


## Signatures
| input     | output                                                                                                                                                                                        |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `record<path: string, name: string, staged: list<string>, unstaged: list<string>, untracked: list<string>, last_commit: record<date: datetime, title: string, hash: string>, branch: string>` |
