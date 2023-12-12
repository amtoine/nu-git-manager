# `nu-git-manager-sugar git gm repo get commit`
## Description
get the commit hash of any revision

# Examples
    get the commit hash of the currently checked out revision
    > gm repo get commit

    get the commit hash of the main branch
    > gm repo get commit main

## Parameters
- parameter_name: revision
- parameter_type: positional
- syntax_shape: string
- is_optional: true
- description: the revision to get the hash of
- parameter_default: HEAD

## Signatures
| input     | output   |
| --------- | -------- |
| `nothing` | `string` |
