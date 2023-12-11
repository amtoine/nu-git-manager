# `nu-git-manager gm squash-forks`
## Description
squash multi-directory forks into a single repo

Here, two forks are defined as *two non-grafted repositories that share the same initial commit,
i.e. that have the same root hash in their respective DAGs*.

By default, `gm squash-forks` will prompt the user for a main fork for each repository with
multiple forks.
Once a *main* fork has been chosen, for each one of the other secondary forks, the command will
preform the following steps:
- add the secondary fork as a remote to the main one
- setup the FETCH and PUSH remotes to the same ones as the secondary fork in the main one
- remove the secondary fork entirely from the store and the cache

This operation can be done in a non-interactive manner by specifying `--non-interactive-preselect`.
This option is a `record` with
- keys: the root hash of repos, e.g. [2ed2d87](https://github.com/amtoine/nu-git-manager/commit/2ed2d875d80505d78423328c6b2a60522715fcdf) for `nu-git-manager`
- values: the main fork to select in full-name form, e.g. `github.com/amtoine/nu-git-manager`

# Examples
    squash forks interactively
    > gm squash-forks

    squash forks non-interactively: `nu-git-manager` and `nushell` to the forks of @amtoine
    > gm squash-forks --non-interactive-preselect {
          2ed2d875d80505d78423328c6b2a60522715fcdf: "github.com/amtoine/nu-git-manager",
          8f3b273337b53bd86d5594d5edc9d4ad7242bd4c: "github.com/amtoine/nushell",
      }

## Signatures
| input     | output    |
| --------- | --------- |
| `nothing` | `nothing` |
