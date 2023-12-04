# `nu-git-manager-sugar extra gm report`
## Description
get a full report about the local store of repositories


## Signature
| input     | output                                                                                                                                                                          |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `table<name: string, branch: string, remote: string, tag: string, index: int, ignored: int, conflicts: int, ahead: int, behind: int, worktree: int, stashes: int, clean: bool>` |
