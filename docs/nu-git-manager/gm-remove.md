# `nu-git-manager gm remove`
## Description
remove one of the repositories from your local store

# Examples
    remove any repository by fuzzy-finding the whole store
    > gm remove --fuzzy

    restrict the search to any one of my repositories
    > gm remove amtoine

    remove a precise repo by giving its full name, a name collision is unlikely
    > gm remove amtoine/nu-git-manager

    remove a precise repo without confirmation
    > gm remove amtoine/nu-git-manager --no-confirm

## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
