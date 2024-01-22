use nu-git-manager [ "gm list" ]

# get a full report about the local store of repositories
#
# ## Examples
# ```nushell
# gm report | columns
# ```
# ```
# ╭────┬───────────╮
# │  0 │ name      │
# │  1 │ branch    │
# │  2 │ remote    │
# │  3 │ tag       │
# │  4 │ index     │
# │  5 │ ignored   │
# │  6 │ conflicts │
# │  7 │ ahead     │
# │  8 │ behind    │
# │  9 │ worktree  │
# │ 10 │ stashes   │
# │ 11 │ clean     │
# ╰────┴───────────╯
# ```
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
        | insert index {|it| (
            $it.idx_added_staged
            + $it.idx_modified_staged
            + $it.idx_deleted_staged
            + $it.idx_renamed
            + $it.idx_type_changed
        )}
        | insert worktree { |it| (
            $it.wt_untracked
            + $it.wt_modified
            + $it.wt_deleted
            + $it.wt_type_changed
            + $it.wt_renamed
        )}
        | select repo_name branch remote tag index ignored conflicts ahead behind worktree stashes
        | rename --column {repo_name: name}
        | update remote {|it| $it.remote | str replace --regex $'/($it.branch)$' '' }
        | update tag { if $in == "no_tag" { null } else { $in } }
        | update remote { if $in == "" { null } else { $in } }
        | insert clean {|it|
            (
                $it.index
                + $it.ignored
                + $it.conflicts
                + $it.ahead
                + $it.behind
                + $it.worktree
                + $it.stashes
            ) == 0
        }
}
