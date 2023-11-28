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
