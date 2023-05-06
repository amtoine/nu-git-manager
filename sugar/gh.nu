def "nu-complete list-repos" [context: string] {
    let user = ($context | str replace 'gh\s*pr\s*open\s*' "" | split row " " | get 0)

    http get ({
        scheme: https,
        username: "",
        host: api.github.com,
        path: $"/orgs/($user)/repos",
        params: {
            sort: updated,
            per_page: 100,
            page: 1
        }
    } | url join)
    | select name description
    | rename value description
}

def "nu-complete gh-status" [] {[
    [value description];

    [failure "The CI does not pass."]
    [pending "The CI is currently running."]
    [success "All the CI jobs have passed."]
]}

def "nu-complete gh-review" [] {[
    [value description];

    [none "No review at all."]
    [changes-requested "There are changes to be applied."]
    [approved "The PR has been approved."]
]}

export def "pr open" [
    owner: string
    repo: string@"nu-complete list-repos"
    --draft: bool
    --ready: bool  # has precedence over `--draft`
    --status: string@"nu-complete gh-status"
    --review: string@"nu-complete gh-review"
] {
    let draft = (if $draft or $ready {
        $draft and (not $ready)
    })

    let query = [
        [is pr]
        [is open]
        [draft $draft]
        [status $status]
        [review $review]
    ]

    let url = ({
        scheme: https,
        host: github.com,
        path: $"/($owner)/($repo)/pulls",
        params: {
            q: (
                $query
                | where {|it| $it.1 != null}
                | each { str join "%3A" }
                | str join "+"
            )
        }
    } | url join)

    xdg-open $url
}

def unpack-pages [] {
    sd -s "}][{" "},{"
}

def pull [
  endpoint: string
] {
    gh api --paginate $endpoint  # get all the raw data
    | unpack-pages               # split the pages into a single one
    | from json                  # convert to JSON internally
}

export def "me notifications" [] {
    pull /notifications
    | select reason subject.title subject.url
    | rename reason title url
    | update url {|notification|
        $notification | get url | url parse
        | update host "github.com"
        | update path {|it|
            $it.path | str replace "/repos/" "" | str replace "pulls" "pull"
        }
        | reject params
        | url join
    }
}

export def "me issues" [] {
    pull /issues
}

export def "me starred" [
    --reduce (-r): bool
] {
    if ($reduce) {
        pull /user/starred
        | select -i id name description owner.login clone_url fork license.name created_at pushed_at homepage archived topics size stargazers_count language
    } else {
        pull /user/starred
    }
}

export def "me repos" [
  owner: string
  --user (-u): bool
] {
    let root = if ($user) { "users" } else { "orgs" }
    pull $"/($root)/($owner)/repos"
}

export def "me protection" [
  owner: string
  repo: string
  branch: string
] {
    pull (["" "repos" $owner $repo "branches" $branch "protection"] | str join "/")
}

export def down [
    project: string
] {
    http get (["https://api.github.com/repos" $project "releases"] | path join)
    | get assets
    | flatten
    | select name download_count created_at
    | update created_at {|r| $r.created_at | into datetime | date format '%m/%d/%Y %H:%M:%S'}
}

export def "me pr" [
    number?: int
    --open-in-browser (-o): bool
] {
    let repo = (
        gh repo view --json nameWithOwner
        | from json
        | try { get nameWithOwner } catch { return }
    )

    if not ($number | is-empty) {
        if $open_in_browser {
            xdg-open ({
                scheme: "https"
                host: "github.com"
                path: ($repo | path join "pull" ($number | into string))
            } | url join)
        } else {
            gh pr checkout $number
        }
        return
    }

    print $"pulling list of PRs for ($repo)..."
    let prs = (
        gh pr list --json title,author,number,createdAt,isDraft,body,url --limit 1000000000
        | from json
        | select number title author.login createdAt isDraft body url
        | rename id title author date draft body url
        | into datetime date
        | sort-by date --reverse
    )

    if ($prs | is-empty) {
        print $"no PR found for project ($repo)!"
        return
    }

    let choice = (
        $prs | each {|pr|
            [
                $pr.id
                $pr.title
                $pr.author
                $pr.date
                $pr.draft
                # ($pr.body | str replace --all '\n' "")
                $pr.url
            ]
            | str join " - "
        }
        | to text
        | fzf
        | str trim
        | split column " - " id title author date draft url
        | get 0
    )

    if ($choice | is-empty) {
        return
    }

    if $open_in_browser {
        xdg-open $choice.url
        return
    }

    print $"checking out onto PR ($choice.id) from ($choice.author)..."
    gh pr checkout $choice.id
}
