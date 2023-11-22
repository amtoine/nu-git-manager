use std log

const GH_ERROR_DEFAULT_HELP = (
    "`(ansi default_dimmed)github query-api(ansi reset)` will default to using "
  + "`(ansi default_dimmed)http get(ansi reset)` and the REST API of GitHub"
)

# throw a warning with pretty error formatting without aborting
#
# # Examples
#     give a warning with no body
#     > warning make {title: "warning"}
#     Error:   × warning
#
#     give a warning with a body
#     > warning make {title: "warning", body: "some message"}
#     Error:   × warning:
#       │ some message
#
#     give a warning with help only
#     > warning make {title: "warning", help: "some help"}
#     Error:   × warning
#       │
#       │ help: some help
#
#     give a complete warning
#     > warning make {title: "warning", body: "some message", help: "some help"}
#     Error:   × warning:
#       │ some message
#       │
#       │ help: some help
def "warning make" [
    warning: record<title: string> # the warning itself: accepts `$.body: string` and `$.help: string` as optional keys
]: nothing -> nothing {
    # FIXME: annotation should be `record<title: string, body: anyof<string, nothing>, help: anyof<string, nothing>>`
    let msg = [$"(ansi yellow_bold)($warning.title)(ansi reset)"]

    let msg = if $warning.body? != null {
        [($msg.0 ++ ':'), $warning.body]
    } else {
        $msg
    }

    let msg = if $warning.help? != null {
        $msg | append [
            ""
            $"(ansi cyan)help(ansi reset): ($warning.help?)"
        ]
    } else {
        $msg
    }

    ^$nu.current-exe [
        --no-config-file
        --no-std-lib
        --commands $"error make --unspanned {msg: $'($msg | str join "\n")'}"
    ]
}

# query the GitHub API for any end point
#
# > :bulb: **Note**  
# > see the [rest API of GitHub](https://docs.github.com/en/rest) for a complete
# > list of available end points and documentation
#
# # Examples
#     list the releases of Nushell sorted by date
#     > github query-api "/repos/nushell/nushell/releases"
#           | select tag_name published_at
#           | rename tag date
#           | into datetime date
#           | sort-by date
#
#     get the bio of @amtoine
#     > github query-api --no-paginate "/users/amtoine" | get bio
#     you shall not rebase in the middle of a PR review nor close other's review threads :pray:
export def "github query-api" [
    end_point: string # the end point in the GitHub API to query
    --page-size: int = 100 # the size of each page
    --no-paginate # do not paginate the API, useful when getting a single record
    --no-gh # force to use `http get` instead of `gh`
]: nothing -> any {
    let use_gh = if $no_gh {
        false
    } else if (which gh --all | where type == external | is-empty) {
        warning make {
                title: "executable_not_found_warning"
                body: (
                    "`(ansi default_dimmed)gh(ansi reset)` was not found in "
                  + "`(ansi default_dimmed)$env.PATH(ansi reset)`"
                )
                help: $GH_ERROR_DEFAULT_HELP
            }

        false
    } else {
        log debug "making sure user is connected to GitHub via `gh`"
        let res = do --ignore-errors { ^gh auth status } | complete

        if $res.exit_code != 0 {
            warning make {
                    title: "github_auth_warning"
                    body: ($res.stderr | str trim)
                    help: $GH_ERROR_DEFAULT_HELP
                }

            false
        } else {
            true
        }
    }

    if $use_gh {
        log debug "pulling pages from GitHub"
        if $no_paginate {
            ^gh api $end_point | from json
        } else {
            ^gh api --paginate $end_point | from json
        }
    } else {
        let base_url = {
            scheme: https,
            host: "api.github.com",
            path: $end_point,
            params: {
                page: null,
                per_page: $page_size
            }
        }

        if $no_paginate {
            http get ($base_url | update params.page 1 | url join)
        } else {
            let res = unfold 1 {|page|
                log debug $"pulling page ($page)"
                let resp = http get ($base_url | update params.page $page | url join)

                let type = $resp | describe | str replace --regex '<.*' ''
                match $type {
                    "table" | "list" => {
                        if ($resp | length) < $page_size {
                            { out: $resp }
                        } else {
                            { out: $resp, next: ($page + 1) }
                        }
                    },
                    _ => {
                        let err_msg = (
                            $"(ansi red_bold)response_not_a_page(ansi reset):\n"

                          +  "expected a page from the API, i.e. a "
                          + $"`(ansi default_dimmed)table(ansi reset)` or a "
                          + $"`(ansi default_dimmed)list(ansi reset)`, received a "
                          + $"`(ansi default_dimmed)($type)(ansi reset)`.\n"

                          +  "\n"

                          + $"(ansi cyan)help(ansi reset): please consider using the "
                          + $"`(ansi default_dimmed)--no-paginate(ansi reset)` option"
                        )
                        error make --unspanned { msg: $err_msg }
                    }
                }
            }

            $res | flatten
        }
    }
}

# list the releases of a GitHub repository
#
# # Examples
#     get the last release of the `github.com:nushell/nushell` repository
#     > github query-releases "nushell/nushell"
#           | into datetime published_at
#           | sort-by published_at
#           | last
#           | select tag_name published_at
export def "github query-releases" [
    repo: string # the GitHub repository to query the releases of
    --page-size: int = 100 # the size of each page
    --no-gh # force to use `http get` instead of `gh`
]: nothing -> table<url: string, assets_url: string, upload_url: string, html_url: string, id: int, author: record<login: string, id: int, node_id: string, avatar_url: string, gravatar_id: string, url: string, html_url: string, followers_url: string, following_url: string, gists_url: string, starred_url: string, subscriptions_url: string, organizations_url: string, repos_url: string, events_url: string, received_events_url: string, type: string, site_admin: bool>, node_id: string, tag_name: string, target_commitish: string, name: string, draft: bool, prerelease: bool, created_at: string, published_at: string, assets: list<any>, tarball_url: string, zipball_url: string, body: string, reactions: record<url: string, total_count: int, +1: int, -1: int, laugh: int, hooray: int, confused: int, heart: int, rocket: int, eyes: int>, mentions_count: int> {
    if $no_gh {
        github query-api $"/repos/($repo)/releases" --page-size $page_size --no-gh
    } else {
        github query-api $"/repos/($repo)/releases" --page-size $page_size
    }
}

# get information about a GitHub user
#
# Examples:
#     get the avatar picture of @amtoine
#     > github query-user amtoine | get avatar_url | http get $in | save --force amtoine.png
export def "github query-user" [
    user: string # the user to query information about
    --no-gh # force to use `http get` instead of `gh`
]: nothing -> record<login: string, id: int, node_id: string, avatar_url: string, gravatar_id: string, url: string, html_url: string, followers_url: string, following_url: string, gists_url: string, starred_url: string, subscriptions_url: string, organizations_url: string, repos_url: string, events_url: string, received_events_url: string, type: string, site_admin: bool, name: string, company: string, blog: string, location: string, email: nothing, hireable: nothing, bio: string, twitter_username: nothing, public_repos: int, public_gists: int, followers: int, following: int, created_at: string, updated_at: string> {
    if $no_gh {
        github query-api $"/users/($user)" --no-paginate --no-gh
    } else {
        github query-api $"/users/($user)" --no-paginate
    }
}
