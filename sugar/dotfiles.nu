export def-env edit [] {
    let choice = (
        git --git-dir $env.DOTFILES_GIT_DIR --work-tree $env.DOTFILES_WORKTREE
            lf ~ --full-name
        | lines
        | input list "Please choose a config file to edit: " --fuzzy
    )
    if ($choice | is-empty) {
        return
    }

    let path = ($env.HOME | path join $choice)

    cd ($path | path dirname)
    ^($env.EDITOR | default "vim") ($path | path basename)
    cd -
}
