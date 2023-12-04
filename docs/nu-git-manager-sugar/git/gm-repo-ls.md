# `nu-git-manager-sugar git gm repo ls`
## Description
get some information about a repo


## Signature
| input   | output                                                                                                                                                           |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| nothing | record<path: string, name: string, staged: int, unstaged: int, untracked: int, last_commit: record<date: datetime, title: string, hash: string>, branch: string> |
