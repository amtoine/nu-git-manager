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
# workarounds for multiple bugs with export use
export module gm {
  use extra.nu gm; export use gm *
  use git/ gm repo; export module repo { export use repo * }
  use github.nu gm gh; export module gh { export use gh * }
  use dotfiles.nu gm cfg; export module cfg { export use cfg * }
}
