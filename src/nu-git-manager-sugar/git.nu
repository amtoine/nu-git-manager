use std log

# get the commit hash of any revision
#
# # Examples
#     get the commit hash of the currently checked out revision
#     > gm repo get commit
#
#     get the commit hash of the main branch
#     > gm repo get commit main
export def "gm repo get commit" [
    revision: string = "HEAD"  # the revision to get the hash of
]: nothing -> string {
    (^git rev-parse $revision)
}

def repo-root [] {
    ^git rev-parse --show-toplevel
}

# go to the root of the repository from anywhere in the worktree
#
# # Examples
#     go back to the root of a repo
#     > cd foo/bar/baz; gm repo goto root; print (pwd)
#     /path/to/repo
export def --env "gm repo goto root" []: nothing -> nothing {
    cd (repo-root)
}

# inspect local branches
#
# > **Note**  
# > in the following, a "*dangling*" branch refers to a branch that does not have any remote
# > counterpart, i.e. it's a purely local branch.
#
# # Examples
#     list branches and their associated remotes
#     > gm repo branches
#
#     clean all dangling branches
#     > gm repo branches --clean
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
] {
    ^git fetch $remote $branch

    if (^git branch --list | lines | str substring 2.. | where $it == $branch | is-empty) {
        log debug $"($branch) was not found locally, creating the branch on top of FETCH_HEAD"
        ^git branch $branch FETCH_HEAD
    } else if (^git branch --show-current) == $branch {
        log debug $"($branch) is currently checkout out, fast-forwarding to FECTH_HEAD"
        ^git rebase $branch FETCH_HEAD
    } else {
        log debug $"moving ($branch) to the new FETCH_HEAD"
        ^git branch --force $branch FETCH_HEAD
    }
}
