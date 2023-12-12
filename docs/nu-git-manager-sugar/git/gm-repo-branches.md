# `nu-git-manager-sugar git gm repo branches`
## Description
inspect local branches

> **Note**  
> in the following, a "*dangling*" branch refers to a branch that does not have any remote
> counterpart, i.e. it's a purely local branch.

# Examples
    list branches and their associated remotes
    > gm repo branches

    clean all dangling branches
    > gm repo branches --clean

## Parameters
- parameter_name: clean
- parameter_type: switch
- is_optional: true
- description: clean all dangling branches

## Signatures
| input     | output                                         |
| --------- | ---------------------------------------------- |
| `nothing` | `table<branch: string, remotes: list<string>>` |
