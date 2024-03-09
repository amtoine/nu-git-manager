# `nu-git-manager-sugar` is the additional module and package of NGM, with sugar
# on top.
#
# it ships things like extensions to the core `gm` command, augments Git with
# automation commands and can provide helper commands around utilities such as
# the GitHub CLI.

module completions.nu
export module extra/
export module git/
export module github/
export module dotfiles/
export module gm {
    export use extra/gm.nu *
    export module git/repo.nu
    export module github/gh.nu
    export module dotfiles/cfg.nu
}
