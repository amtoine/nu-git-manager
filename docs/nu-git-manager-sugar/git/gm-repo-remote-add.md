# `gm repo remote add` from `nu-git-manager-sugar git` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/git/mod.nu#L202))
add a remote to the current repository

> **Note**  
> will throw an error if `$remote` does not appear to be a valid URL.

## Examples
```nushell
# add `https://www.example.com` to the remotes as `upstream`
gm repo remote add upstream https://www.example.com
```
---
```nushell
# add `https://www.example.com` to the remotes as `upstream`, using the SSH protocol
gm repo remote add upstream https://www.example.com --ssh
```

## Parameters
- `name` <`string`>: 
- `remote` <`string`>: 
- `--ssh` <`bool`>: 


## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
