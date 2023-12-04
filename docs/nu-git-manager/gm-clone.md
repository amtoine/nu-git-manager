# `nu-git-manager gm clone`
## Description
clone a remote Git repository into your local store
will give a nice error if the repository is already in the local store.

# Examples
    clone a repository in the local store of `nu-git-manager`
    > gm clone https://github.com/amtoine/nu-git-manager

    clone as a bare repository, i.e. a repo without a worktree
    > gm clone --bare https://github.com/amtoine/nu-git-manager

    clone a repo and change the name of the remote
    > gm clone --remote default https://github.com/amtoine/nu-git-manager

    setup a public repo in the local store and use HTTP to fetch without PAT and push with SSH
    > gm clone https://github.com/amtoine/nu-git-manager --fetch https --push ssh

    clone a big repo as a single commit, avoiding all intermediate Git deltas
    > gm clone https://github.com/neovim/neovim --depth 1

## Signature
| input   | output  |
| ------- | ------- |
| nothing | nothing |
