# `nu-git-manager-sugar` is the additional module and package of NGM, with sugar
# on top.
#
# it ships things like extensions to the core `gm` command, augments Git with
# automation commands and can provide helper commands around utilities such as
# the GitHub CLI.

module completions.nu
export module extra.nu
export module git/
export module github.nu
export module dotfiles.nu
# workarounds below explained in #184
export module gm {
    use extra.nu gm; export use gm *
    export module repo {
        use git/ gm repo; export use repo *
    }
    export module gh {
        use github.nu gm gh; export use gh *
    }
    export module cfg {
        use dotfiles.nu gm cfg; export use cfg *
    }
}
