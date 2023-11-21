use log debug

# TODO: documentation
export def "gm branch wipe" [
    branch: string, # TODO: documentation
    remote: string, # TODO: documentation
] {
    git branch --delete --force $branch
    git push $remote --delete $branch
}

# TODO: documentation
export def "gm report" [
    --dirty # list only dirty repositories
]: nothing -> table<name: string, branch: string, remote: string, tag: string, index: int, ignored: int, conflicts: int, ahead: int, behind: int, worktree: int, stashes: int> {
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

    let report = $repos
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

    if $dirty {
        $report | where not clean | reject clean
    } else {
        $report
    }
}

# TODO: documentation
export def "gm fetch branch" [
    remote: string, # TODO: documentation
    branch: string, # TODO: documentation
] {
    git fetch $remote $branch

    if (git branch --list | lines | str substring 2.. | where $it == $branch | is-empty) {
        log debug $"($branch) was not found locally, creating the branch on top of FETCH_HEAD"
        git branch $branch FETCH_HEAD
    } else if (git branch --show-current) == $branch {
        log debug $"($branch) is currently checkout out, fast-forwarding to FECTH_HEAD"
        git rebase $branch FETCH_HEAD
    } else {
        log debug $"moving ($branch) to the new FETCH_HEAD"
        git branch --force $branch FETCH_HEAD
    }
}

# TODO: documentation
export def "gm compare" [
    target: string, # TODO: documentation
    --head: string = "HEAD", # TODO: documentation
] {
    git diff (git merge-base $target $head) $head
}

def get-branches [--merged, --no-merged]: nothing -> list<string> {
    let branches = if $merged {
        ^git branch --merged
    } else if $no_merged {
        ^git branch --no-merged
    } else {
        ^git branch
    }

    $branches | lines | str substring 2..
}

# TODO: documentation
export def "gm repo branch interactive-delete" [] {
    let choice = get-branches | input list --multi "remove"
    if ($choice | is-empty) {
        return
    }

    let not_merged = get-branches --no-merged
    let merged = get-branches --merged

    ^git branch --delete ($choice | where $it in $merged)

    let choice = $choice | where $it in $not_merged | input list --multi "sure?"
    if ($choice | is-empty) {
        return
    }

    ^git branch --delete --force $choice
}

export def "gm repo switch" []: nothing -> nothing {
    let res = ^git branch --all
        | lines
        | str replace --regex '^  (remotes/.*)' $'  (ansi default_dimmed)${1}(ansi reset)'
        | str replace --regex '^\* (.*)' $'(ansi cyan_bold)${1}(ansi reset)'
        | str trim
        | input list --fuzzy

    if $res == null {
        return
    }

    let branch = $res | ansi strip

    let branch = if ($branch | str starts-with "remotes/") {
        $branch | split row '/' | skip 2 | str join '/'
    } else {
        $branch
    }

    git checkout $branch
}
