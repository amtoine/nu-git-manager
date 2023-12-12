# `gm repo ls` (`nu-git-manager-sugar git`)
get some information about a repo



## Parameters
- parameter_name: repo
- parameter_type: positional
- syntax_shape: path
- is_optional: true
- description: the path to the repo (defaults to `.`)

## Signatures
| input     | output                                                                                                                                                             |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `nothing` | `record<path: string, name: string, staged: int, unstaged: int, untracked: int, last_commit: record<date: datetime, title: string, hash: string>, branch: string>` |
