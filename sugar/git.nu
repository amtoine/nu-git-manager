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
export def "get commit" [
    revision: string = "HEAD"  # the revision to get the hash of (defaults to "HEAD")
] {
    git rev-parse $revision | str trim
}

# compare two revisions in a `git` repository
export def compare [
    with: string  # the target revision to compare the base with
    from: string = "HEAD"  # the base revision of the comparison (defaults to "HEAD")
    --share: bool  # output the comparision in pretty shareable format
] {
    let start = (git rev-parse $with | str trim)
    let end = (git rev-parse $from | str trim)

    if $share {
        return $"[`($start)`..`($end)`]\(($start)..($end)\)"
    }

    print $"comparing ($start) ($with) and ($end) ($from)"
    git diff $start $end
}

def repo-root [] {
    git rev-parse --show-toplevel | str trim
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
export def-env root [] {
    cd (repo-root)
}

# inspect local branches
#
# without any options, `git branches` will show all dangling branches, i.e.
# local branches that do not have a remote counterpart.
export def branches [
    --report: bool  # will give a table report of all the
    --clean: bool  # clean all dangling branches
] {
    let local_branches = (git branch --list | lines | str replace '..' "")
    let remote_branches = (git branch -r | lines | str trim | find --invert "HEAD ->" | parse "{remote}/{branch}")

    let branches_report = (
        $local_branches | each {|branch|
            {
                branch: $branch
                remotes: ($remote_branches | where branch == $branch | get remote)
            }
        }
    )

    if $report {
        return $branches_report
    }

    let dangling_branches = ($branches_report | where remotes == [] | get branch)

    if ($dangling_branches | length) == 0 {
        print "no dangling branch"
        return
    }

    if $clean {
        $dangling_branches | each {|| git branch --delete --force $in}
    } else {
        $dangling_branches
    }
}
