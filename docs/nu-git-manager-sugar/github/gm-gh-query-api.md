# `gm gh query-api` from `nu-git-manager-sugar github` (see [source](https://github.com/amtoine/nu-git-manager/blob/main/pkgs/nu-git-manager-sugar/nu-git-manager-sugar/github.nu#L83))
query the GitHub API for any end point

> :bulb: **Note**  
> see the [rest API of GitHub](https://docs.github.com/en/rest) for a complete
> list of available end points and documentation

## Examples
```nushell
# list the releases of Nushell sorted by date
gm gh query-api "/repos/nushell/nushell/releases"
    | select tag_name published_at
    | rename tag date
    | into datetime date
    | sort-by date
```
---
```nushell
# get the bio of @amtoine
gm gh query-api --no-paginate "/users/amtoine" | get bio
```
```
you shall not rebase in the middle of a PR review nor close other's review threads :pray:
```

## Parameters
- `end_point` <`string`>: the end point in the GitHub API to query
- `--page-size` <`int`> = `100`: the size of each page
- `--no-paginate` <`bool`>: do not paginate the API, useful when getting a single record
- `--no-gh` <`bool`>: force to use `http get` instead of `gh`


## Signatures
| input     | output |
| --------- | ------ |
| `nothing` | `any`  |
