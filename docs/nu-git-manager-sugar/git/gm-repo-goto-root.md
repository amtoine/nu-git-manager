# `gm repo goto root` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L56))
go to the root of the repository from anywhere in the worktree

## Examples
```nushell
# go back to the root of a repo
cd foo/bar/baz; gm repo goto root; print (pwd)
```
```
/path/to/repo
```

## Parameters


## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
