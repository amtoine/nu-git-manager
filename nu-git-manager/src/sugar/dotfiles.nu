# choose a config file to edit with fuzzy finding
#
# `dotfiles edit` requires the following environment variables to be defined:
# - `$env.DOTFILES_GIT_DIR`: the path to the *bare* repository
# - `$env.DOTFILES_WORKTREE`: the path to the worktree, e.g. `$env.HOME`
# - `$env.EDITOR`: will default to `vim`
#
# this command will `cd` into the directory where the chosen file is to allow
# easier editing and will use the `EDITOR`.
export def-env edit [] {
    let choice = (
        git --git-dir $env.DOTFILES_GIT_DIR --work-tree $env.DOTFILES_WORKTREE
            lf ~ --full-name
        | lines
        | input list --fuzzy
            $"Please (ansi yellow_italic)choose a config(ansi reset) file to (ansi blue_underline)edit(ansi reset): "
        | into string
    )
    if ($choice | is-empty) {
        return
    }

    let path = ($env.HOME | path join $choice)

    cd ($path | path dirname)
    ^($env.EDITOR | default "vim") ($path | path basename)
    cd -
}
