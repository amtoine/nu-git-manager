export def operations [] {
    git log $"(git merge-base FETCH_HEAD main)..HEAD" -M5 --summary
    | rg -e 'rename.*=>|delete mode'
    | lines
    | str trim
    | parse '{operation} {file}'
    | sort-by operation
}

export def "get commit" [
    revision: string = "HEAD"
] {
    git rev-parse $revision | str trim
}

export def compare [
    with: string
    from: string = "HEAD"
    --share: bool
] {
    let start = (git rev-parse $with | str trim)
    let end = (git rev-parse $from | str trim)

    if $share {
        return $"[`($start)`..`($end)`]\(($start)..($end)\)"
    }

    print $"comparing ($start) ($with) and ($end) ($from)"
    git diff $start $end
}

export def "lock clean" [] {
    try {
        rm --verbose (git rev-parse --show-toplevel | str trim | path join ".git" "index.lock")
    } catch {
        print "the index is not busy for now."
    }
}

export def-env root [] {
    cd (git rev-parse --show-toplevel | str trim)
}

export def branches [
    --report: bool
    --clean: bool
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
