# the `dotfiles` module ships the `gm cfg` command
#
# the goal of `gm cfg` is to provide tools to interact with dotfiles managed
# through a _bare_ repo.

# manage dotfiles from anywhere
#
# this command is basically a thin wrapper around the `git` command... but for
# _bare_ dotfiles.
#
# `gm cfg` requires the following environment variables to be defined
# - `DOTFILES_GIT_DIR`: the location where to find the _bare_ repo of the
#     dotfiles, e.g. `~/documents/repos/dotfiles` or something like
#     `$env.GIT_REPOS_HOME | path join "github.com" "amtoine" "dotfiles"`
# - `DOTFILES_WORKTREE`: the actual worktree where the dotfiles live, e.g. the
#     home directory
#
# # Examples
# ```nushell
# # list all the files that are tracked as dotfiles
# gm cfg ls-files ~
# ```
# ---
# ```nushell
# # get the current status of the dotfiles in short format
# gm status --short
# ```
export def --wrapped "gm cfg" [...args] {
    ^git --git-dir $env.DOTFILES_GIT_DIR --work-tree $env.DOTFILES_WORKTREE ...$args
}

def "ansi cmd" []: string -> string {
    $"`(ansi default_dimmed)($in)(ansi reset)`"
}

# edit any config file tracked as dotfiles
#
# this command will
# - let you fuzzy search amongst all the dotfiles
# - switch to the parent directory of the selected dotfile
# - open the selected dotfile in `$env.EDITOR`
export def "gm cfg edit" [] {
    let git_options = [
        --git-dir $env.DOTFILES_GIT_DIR
        --work-tree $env.DOTFILES_WORKTREE
    ]

    let prompt = $"choose a config file to (ansi cyan_bold)edit(ansi reset):"
    let choice = ^git ...$git_options ls-files --full-name $env.DOTFILES_WORKTREE
        | lines
        | input list --fuzzy $prompt
    if ($choice | is-empty) {
        return
    }

    let config_file = $env.DOTFILES_WORKTREE | path join $choice

    cd ($config_file | path dirname)
    ^$env.EDITOR $config_file
}
