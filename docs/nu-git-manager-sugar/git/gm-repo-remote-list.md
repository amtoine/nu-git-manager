# `nu-git-manager-sugar git gm repo remote list`
## Description
get the list of all the remotes in the current repository
# Examples
    list all the remotes in a default `nu-git-manager` repo
    > gm repo remote list
    #┬remote┬──────────────────fetch──────────────────┬─────────────────push──────────────────
    0│origin│https://github.com/amtoine/nu-git-manager│ssh://github.com/amtoine/nu-git-manager
    ─┴──────┴─────────────────────────────────────────┴───────────────────────────────────────


## Signature
| input     | output                                               |
| --------- | ---------------------------------------------------- |
| `nothing` | `table<remote: string, fetch: string, push: string>` |
