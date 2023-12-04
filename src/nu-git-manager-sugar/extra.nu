use completions/nu-complete.nu [GIT_QUERY_TABLES, git-query-tables]

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

export def "gm repo query" [table: string@git-query-tables] {
    if $table not-in $GIT_QUERY_TABLES {
        error make {
            msg: $"(ansi red_bold)invalid_qit_query_table(ansi reset)",
            label: {
                text: $"expected one of ($GIT_QUERY_TABLES), got '($table)'"
                span: (metadata $table).span,
            }
        }
    }

    if (which "query git" | is-empty) {
        error make --unspanned {
            msg: (
                $"(ansi red_bold)requirement_not_found(ansi reset):\n"
              + $"could not find `(ansi default_dimmed)query git(ansi reset)` in current scope\n"
              +  "\n"
              + $"(ansi cyan)help(ansi reset): install the (ansi blue_dimmed)[`(ansi reset)(ansi blue_bold)nu_plugin_query_git(ansi reset)(ansi blue_dimmed)`]\(https://github.com/fdncred/nu_plugin_query_git\)(ansi reset) plugin with `(ansi default_dimmed)cargo build --release(ansi reset)` and then `(ansi default_dimmed)register(ansi reset)` it"
            )
        }
    }

    query git $"select * from ($table)"
}
