use std log

# get a summary of all the operations made between `main` and `HEAD`
export def operations [] {
    git log $"(git merge-base FETCH_HEAD main)..HEAD" -M5 --summary
    | rg -e 'rename.*=>|delete mode'
    | lines
    | str trim
    | parse '{operation} {file}'
    | sort-by operation
}

# get the commit hash of any revision
export def "gm repo get commit" [
    revision: string = "HEAD"  # the revision to get the hash of
]: nothing -> string {
    ^git rev-parse $revision
}

# compare two revisions in a `git` repository
export def compare [
    with: string  # the target revision to compare the base with
    from: string = "HEAD"  # the base revision of the comparison (defaults to "HEAD")
    --share  # output the comparision in pretty shareable format
] {
    let start = (git rev-parse $with | str trim)
    let end = (git rev-parse $from | str trim)

    if $share {
        return $"[`($start)`..`($end)`]\(($start)..($end)\)"
    }

    print $"comparing ($start) (char lparen)($with)(char rparen) and ($end) (char lparen)($from)(char rparen)"
    git diff $start $end
}

def repo-root [] {
    ^git rev-parse --show-toplevel
}

# removes the index lock
#
# sometimes `git` won't want to run a command because of the `.git/index.lock` file not being
# cleared...
# this command simply removes the lock for you.
export def "lock clean" [] {
    try {
        rm --verbose (repo-root | path join ".git" "index.lock")
    } catch {
        print "the index is not busy for now."
    }
}

# go to the root of the repository from anywhere in the worktree
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

# return true iif the first revision is an ancestor of the second
export def is-ancestor [
    a: string  # the base commit-ish revision
    b: string  # the *head* commit-ish revision
] {
    let exit_code = (do -i {
        git merge-base $a $b --is-ancestor
    } | complete | get exit_code)

    $exit_code == 0
}

# get the list of all the remotes in the current repository
export def "remote list" [] {
    ^git remote --verbose
    | detect columns --no-headers
    | rename remote url mode
    | str trim
    | group-by remote
    | transpose
    | update column1 { reject remote | select mode url | transpose -r | into record }
    | flatten
    | rename remote fetch push
}

# add a new remote to the repository
export def "remote add" [
    name: string  # the name of the remote, e.g. `amtoine`
    repo: string  # the name of the upstream repo, e.g. `nu-git-manager`
    host: string  # the host where the upstream repo is stored, e.g. `github.com`
    --ssh  # use SSH as the communication protocol
] {
    if $name in (remote list | get remote) {
        error make {
            msg: $"(ansi red_bold)remote_already_in_index(ansi reset)"
            label: {
                text: $"already a remote of ($env.PWD)"
                span: (metadata $name | get span)
            }
        }
    }

    let url = if $ssh {
        $"git@($host):($name)/($repo)"
    } else {
        $"https://($host)/($name)/($repo)"
    }

    ^git remote add $name $url

    remote list | each {|it|
        if $it.remote == $name {
            $it | transpose | update column1 { $"(ansi yellow_bold)($in)(ansi reset)" } | transpose -r | into record
        } else { $it }
    }
}

def "nu-complete remotes" [] {
    remote list | get remote
}

# remove a remote from the local repository
export def "remote remove" [
    ...remotes: string@"nu-complete remotes"  # a *rest* list of remotes
] {
    let report = (
        remote list | each {|it|
            if $it.remote in $remotes {
                $it | transpose | update column1 { $"(ansi red_bold)($in)(ansi reset)" } | transpose -r | into record
            } else { $it }
        }
    )

    $remotes | each {|remote|
        if not ($remote in (remote list | get remote)) {
            log warning $"($remote) is not a remote of ($env.PWD)"
        } else {
            log info $"removing ($remote) from ($env.PWD)"
            ^git remote remove $remote
        }
    } | ignore

    $report
}

# fixup a revision that's not the latest commit
export def fixup [
    revision: string  # the revision of the Git worktree to fixup
] {
    if (do --ignore-errors { git rev-parse $revision } | complete | get exit_code) != 0 {
        error make {
            msg: $"(ansi red_bold)revision_not_found(ansi reset)"
            label: {
                text: $"($revision) not found in the working tree of ($env.PWD)"
                span: (metadata $revision | get span)
            }
        }
    }

    git commit --fixup $revision
    git rebase --interactive --autosquash $"($revision)~1"
}
