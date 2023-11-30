# get a full report about the local store of repositories
export def "gm report" []: nothing -> table<name: string, branch: string, remote: string, tag: string, index: int, ignored: int, conflicts: int, ahead: int, behind: int, worktree: int, stashes: int, clean: bool> {
    if (which gstat | is-empty) {
        error make --unspanned {
            msg: (
                $"(ansi red_bold)requirement_not_found(ansi reset):\n"
              + $"could not find `(ansi default_dimmed)gstat(ansi reset)` in the scope\n"
              +  "\n"
              + $"(ansi cyan)help(ansi reset): install the plugin with `(ansi default_dimmed)cargo install nu_plugin_gstat(ansi reset)` and then `(ansi default_dimmed)register(ansi reset)` it"
            )
        }
    }

    let repos = gm list --full-path
    $repos
        | enumerate
        | each {|it|
            print --no-newline $"(ansi erase_line)[($it.index + 1) / ($repos | length)]: ($it.item)\r"
            { path: $it.item } | merge (gstat $it.item)
        }
        | insert index {(
            $in.idx_added_staged
            + $in.idx_modified_staged
            + $in.idx_deleted_staged
            + $in.idx_renamed
            + $in.idx_type_changed
        )}
        | insert worktree {(
            $in.wt_untracked
            + $in.wt_modified
            + $in.wt_deleted
            + $in.wt_type_changed
            + $in.wt_renamed
        )}
        | select repo_name branch remote tag index ignored conflicts ahead behind worktree stashes
        | rename --column {repo_name: name}
        | update remote {|it| $it.remote | str replace --regex $'/($it.branch)$' '' }
        | update tag { if $in == "no_tag" { null } else { $in } }
        | update remote { if $in == "" { null } else { $in } }
        | insert clean {
            (
                $in.index
                + $in.ignored
                + $in.conflicts
                + $in.ahead
                + $in.behind
                + $in.worktree
                + $in.stashes
            ) == 0
        }
}

# run a piece of code on all the repositories of the local store
#
# depending on the code given to `gm for-each`, the command might return any
# kind of data, e.g. nothing or a table.
#
# the name of each repo will be passed as the first and only argument.
#
# # Examples
#     get the status of all the repos: empty list
#     > gm for-each { git status }
#
#     get the number of files tracked by each repo: list<int>
#     > gm for-each { git lf | lines | length }
#
#     get the number of status lines of each repo: table<repo: string, status: int>
#     > gm for-each { |r| {
#           repo: $r,
#           status: (git status --short | lines | length)
#       } }
export def "gm for-each" [code: closure]: nothing -> any {
    let root = gm status | get root.path

    gm list | each {|repo|
        cd ($root | path join $repo)
        do $code $repo
    }
}
