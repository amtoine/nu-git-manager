# `nu-git-manager gm list`
## Description
list all the local repositories in your local store
/!\ this command will return sanitized paths. /!\

# Examples
    list all the repositories in the store
    > gm list

    list all the repositories in the store with their full paths
    > gm list --full-path

    jump to a directory in the store
    > cd (gm list --full-path | input list)

## Signature
| input     | output         |
| --------- | -------------- |
| `nothing` | `list<string>` |
