# `gm gh query-releases` (`nu-git-manager-sugar github`)
list the releases of a GitHub repository

## Examples
```nushell
# get the last release of the `github.com:nushell/nushell` repository
gm gh query-releases "nushell/nushell"
    | into datetime published_at
    | sort-by published_at
    | last
    | select tag_name published_at
```

## Parameters
- parameter_name: repo
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the GitHub repository to query the releases of
---
- parameter_name: page-size
- parameter_type: named
- syntax_shape: int
- is_optional: true
- description: the size of each page
- parameter_default: 100
---
- parameter_name: no-gh
- parameter_type: switch
- is_optional: true
- description: force to use `http get` instead of `gh`

## Signatures
| input     | output                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `table<url: string, assets_url: string, upload_url: string, html_url: string, id: int, author: record<login: string, id: int, node_id: string, avatar_url: string, gravatar_id: string, url: string, html_url: string, followers_url: string, following_url: string, gists_url: string, starred_url: string, subscriptions_url: string, organizations_url: string, repos_url: string, events_url: string, received_events_url: string, type: string, site_admin: bool>, node_id: string, tag_name: string, target_commitish: string, name: string, draft: bool, prerelease: bool, created_at: string, published_at: string, assets: list<any>, tarball_url: string, zipball_url: string, body: string, reactions: record<url: string, total_count: int, +1: int, -1: int, laugh: int, hooray: int, confused: int, heart: int, rocket: int, eyes: int>, mentions_count: int>` |
