# the `dotfiles` module ships the `gm cfg` command
#
# the goal of `gm cfg` is to provide tools to interact with dotfiles managed
# through a _bare_ repo.
export module gm { export module cfg {

def "options" [
    git_dir?: string
    work_tree?: string
]: nothing -> record<GIT_DIR: string, GIT_WORK_TREE: string> {
    {
        GIT_DIR: ($git_dir | default $env.DOTFILES_GIT_DIR)
        GIT_WORK_TREE: ($work_tree | default $env.HOME)
    }
}

# manage dotfiles from anywhere
#
# this command is basically a thin wrapper around the `git` command... but for
# _bare_ dotfiles.
#
# `gm cfg` loads the following environment variables
# - `DOTFILES_GIT_DIR`: the location where to find the _bare_ repo of the
#     dotfiles, e.g. `~/documents/repos/dotfiles` or something like
#     `$env.GIT_REPOS_HOME | path join "github.com" "amtoine" "dotfiles"`
# - `HOME`: the actual worktree where the dotfiles live, unless overidden by
#     `--work-tree`
#
# # Examples
# ```nushell
# # list all the files that are tracked as dotfiles
# gm cfg ls-files ~
# ```
# ---
# ```nushell
# # get the current status of the dotfiles in short format
# gm cfg status --short
# ```
# ---
# ```nushell
# # visualize dotfiles in Lazygit
# gm cfg { lg }
# ```
export def --wrapped "main" [
    cmd: any
    ...args # implicit any instead of string required by --wrapped
    --git-dir: string
    --work-tree: string
]: nothing -> any {
    options $git_dir $work_tree | load-env
    if ($cmd | describe) == closure {
        do $cmd ...$args  # even works with gm!
    }  else {
        ^git $cmd ...$args
    }
}

def "ansi cmd" []: string -> string {
    $"`(ansi default_dimmed)($in)(ansi reset)`"
}

# edit any config file tracked as dotfiles
#
# this command will
# - let you fuzzy search amongst all the dotfiles
# - switch to the parent directory of the selected dotfile
# - open the selected dotfile in `$env.VISUAL` or `$env.EDITOR`
export def "edit" [
    editor?: string
    --git-dir: string
    --work-tree: string
]: nothing -> nothing {
    alias cfg = main --git-dir $git_dir --work-tree $work_tree

    let work_tree = (options $git_dir $work_tree).GIT_WORK_TREE
    let prompt = $"choose a config file to (ansi cyan_bold)edit(ansi reset):"
    let choice = cfg ls-files --full-name $work_tree
        | lines
        | input list --fuzzy $prompt
    if ($choice | is-empty) {
        return
    }

    let config_file = $work_tree | path join $choice

    cd ($config_file | path dirname)
    let editor = $editor
        | default $env.VISUAL?
        | default $env.EDITOR?
        | default nano
        # if they haven't defined these they might not know vi either
    ^$editor $config_file
}

} }
