# `gm report` (`nu-git-manager-sugar extra`)
get a full report about the local store of repositories

## Examples
```nushell
gm report | columns
```
```
╭────┬───────────╮
│  0 │ name      │
│  1 │ branch    │
│  2 │ remote    │
│  3 │ tag       │
│  4 │ index     │
│  5 │ ignored   │
│  6 │ conflicts │
│  7 │ ahead     │
│  8 │ behind    │
│  9 │ worktree  │
│ 10 │ stashes   │
│ 11 │ clean     │
╰────┴───────────╯
```

## Parameters


## Signatures
| input     | output                                                                                                                                                                          |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `table<name: string, branch: string, remote: string, tag: string, index: int, ignored: int, conflicts: int, ahead: int, behind: int, worktree: int, stashes: int, clean: bool>` |
