use std log

use ../git/lib/lib.nu [get-status]

# get the commit hash of any revision
#
# ## Examples
# ```nushell
# # get the commit hash of the currently checked out revision
# gm repo get commit
# ```
# ---
# ```nushell
# # get the commit hash of the main branch
# gm repo get commit main
# ```
export def "gm repo get commit" [
    revision: string = "HEAD"  # the revision to get the hash of
]: nothing -> string {
    (^git rev-parse $revision)
}

# compare the changes between two revisions, from a target to the "head"
export def "gm repo compare" [
    target: string, # the target to compare from
    --head: string = "HEAD", # the "head" to use for the comparison
] {
    ^git diff (^git merge-base $target $head) $head
}

def repo-root [] {
    ^git rev-parse --show-toplevel
}

# go to the root of the repository from anywhere in the worktree
#
# ## Examples
# ```nushell
# # go back to the root of a repo
# cd foo/bar/baz; gm repo goto root; print (pwd)
# ```
# ```
# /path/to/repo
# ```
export def --env "gm repo goto root" []: nothing -> nothing {
    cd (repo-root)
}

# inspect local branches
#
# > **Note**  
# > in the following, a "*dangling*" branch refers to a branch that does not have any remote
# > counterpart, i.e. it's a purely local branch.
#
# ## Examples
# ```nushell
# # list branches and their associated remotes
# gm repo branches
# ```
# ---
# ```nushell
# # clean all dangling branches
# gm repo branches --clean
# ```
export def "gm repo branches" [
    --clean  # clean all dangling branches
]: nothing -> table<branch: string, remotes: list<string>> {
    let local_branches = ^git branch --list | lines | str replace --regex '..' ""
    let remote_branches = ^git branch --remotes
        | lines
        | str trim
        | find --invert "HEAD ->"
        | parse "{remote}/{branch}"

    let branches = $local_branches | each {|branch| {
        branch: $branch
        remotes: ($remote_branches | where branch == $branch | get remote)
    } }

    if $clean {
        let dangling_branches = $branches | where remotes == []

        if ($dangling_branches | is-empty) {
            log warning "no dangling branches"
            return
        }

        for branch in $dangling_branches.branch {
            if $branch == (^git branch --show-current) {
                log warning $"($branch) is currently checked out and cannot be deleted"
                continue
            }

            log info $"deleting branch `($branch)`"
            ^git branch --quiet --delete --force $branch
        }
    } else {
        $branches
    }
}

# wipe a branch completely, i.e. both locally and remotely
export def "gm repo branch wipe" [
    branch: string, # the branch to wipe
    remote: string, # the remote to push to
] {
    ^git branch --delete --force $branch
    ^git push $remote --delete $branch
}


# return true iif the first revision is an ancestor of the second
#
# # Examples
#     HEAD~20 is an ancestor of HEAD
#     > gm repo is-ancestor HEAD~20 HEAD
#     true
#
#     HEAD is never an ancestor of HEAD~20
#     > gm repo is-ancestor HEAD HEAD~20
#     false
export def "gm repo is-ancestor" [
    a: string  # the base commit-ish revision
    b: string  # the *head* commit-ish revision
]: nothing -> bool {
    (do -i { ^git merge-base $a $b --is-ancestor } | complete | get exit_code) == 0
}

# get the list of all the remotes in the current repository
# # Examples
#     list all the remotes in a default `nu-git-manager` repo
#     > gm repo remote list
#     #┬remote┬──────────────────fetch──────────────────┬─────────────────push──────────────────
#     0│origin│https://github.com/amtoine/nu-git-manager│ssh://github.com/amtoine/nu-git-manager
#     ─┴──────┴─────────────────────────────────────────┴───────────────────────────────────────
export def "gm repo remote list" []: nothing -> table<remote: string, fetch: string, push: string> {
    # FIXME: use the helper `list-remotes` command from ../nu-git-manager/git/repo.nu:29
    ^git remote --verbose
        | detect columns --no-headers
        | rename remote url mode
        | group-by remote
        | transpose
        | update column1 {
            reject remote | select mode url | transpose --header-row | into record
        }
        | flatten
        | rename remote fetch push
}

# fetch a remote branch locally, without pulling down the whole remote
export def "gm repo fetch branch" [
    remote: string, # the branch to fetch
    branch: string, # the remote to fetch the branch from
    --strategy: string = "none" # the merge strategy to use
] {
    ^git fetch $remote $branch

    if (^git branch --list | lines | str substring 2.. | where $it == $branch | is-empty) {
        log debug $"($branch) was not found locally, creating the branch on top of FETCH_HEAD"
        ^git branch $branch FETCH_HEAD
    } else if (^git branch --show-current) == $branch {
        log debug $"($branch) is currently checked out"
        match $strategy {
            "rebase" => {
                log debug "rebasing to FECTH_HEAD according to strategy"
                ^git rebase FETCH_HEAD $branch
            },
            "merge" => {
                log debug "fast-forwarding to FECTH_HEAD according to strategy"
                ^git merge $branch FETCH_HEAD
            },
            "none" => { log debug "not doing anything according to strategy" },
            _ => {
                # FIXME: should be using the `throw-error` command from `nu-git-manager`
                error make {
                    msg: $"(ansi red_bold)invalid_strategy(ansi reset)"
                    label: {
                        text: "expected one of ['merge', 'rebase', 'none']"
                        span: (metadata $strategy).span
                    }
                }
            },
        }
    } else {
        log debug $"moving ($branch) to the new FETCH_HEAD"
        ^git branch --force $branch FETCH_HEAD
    }
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

# remove a branch interactively
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

# switch between branches interactively
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

    ^git checkout $branch
}

# get some information about a repo
export def "gm repo ls" [
    repo?: path, # the path to the repo (defaults to `.`)
]: nothing -> record<path: path, name: string, staged: list<string>, unstaged: list<string>, untracked: list<string>, last_commit: record<date: datetime, title: string, hash: string>, branch: string> {
    let repo = $repo | default (pwd)
    let status = get-status $repo

    let last_commit = if (do --ignore-errors { git -C $repo log -1 } | complete).exit_code == 0 { {
        date: (^git -C $repo log -1 --format=%cd | into datetime),
        title: (^git -C $repo log -1 --format=%s),
        hash: (^git -C $repo log -1 --format=%h),
    } } else {
        null
    }

    {
        # FIXME: should be using `path sanitize` defined in `nu-git-manager`
        path: ($repo | str replace --regex '^.:' '' | str replace --all '\' '/'),
        name: ($repo | path basename),
        staged: $status.staged,
        unstaged: $status.unstaged,
        untracked: $status.untracked,
        last_commit: $last_commit,
        branch: (^git -C $repo branch --show-current),
    }
}
