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

## Parameters
- parameter_name: full-path
- parameter_type: switch
- is_optional: true
- description: show the full path instead of only the "owner + group + repo" name

## Signatures
| input     | output         |
| --------- | -------------- |
| `nothing` | `list<string>` |
