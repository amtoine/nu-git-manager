# `gm gh query-user` from `nu-git-manager-sugar github` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/github.nu#L207))
get information about a GitHub user

## Examples:
```nushell
# get the avatar picture of @amtoine
gm gh query-user amtoine | get avatar_url | http get $in | save --force amtoine.png
```

## Parameters
- `user` <`string`>: the user to query information about
- `--no-gh` <`bool`>: force to use `http get` instead of `gh`


## Signatures
| input     | output                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nothing` | `record<login: string, id: int, node_id: string, avatar_url: string, gravatar_id: string, url: string, html_url: string, followers_url: string, following_url: string, gists_url: string, starred_url: string, subscriptions_url: string, organizations_url: string, repos_url: string, events_url: string, received_events_url: string, type: string, site_admin: bool, name: string, company: string, blog: string, location: string, email: nothing, hireable: nothing, bio: string, twitter_username: nothing, public_repos: int, public_gists: int, followers: int, following: int, created_at: string, updated_at: string>` |
