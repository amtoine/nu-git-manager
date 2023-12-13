# `nu-git-manager-sugar github gm gh query-api`
## Description
query the GitHub API for any end point

> :bulb: **Note**  
> see the [rest API of GitHub](https://docs.github.com/en/rest) for a complete
> list of available end points and documentation

# Examples
    list the releases of Nushell sorted by date
    > gm gh query-api "/repos/nushell/nushell/releases"
          | select tag_name published_at
          | rename tag date
          | into datetime date
          | sort-by date

    get the bio of @amtoine
    > gm gh query-api --no-paginate "/users/amtoine" | get bio
    you shall not rebase in the middle of a PR review nor close other's review threads :pray:

## Parameters
- parameter_name: end_point
- parameter_type: positional
- syntax_shape: string
- is_optional: false
- description: the end point in the GitHub API to query
---
- parameter_name: page-size
- parameter_type: named
- syntax_shape: int
- is_optional: true
- description: the size of each page
- parameter_default: 100
---
- parameter_name: no-paginate
- parameter_type: switch
- is_optional: true
- description: do not paginate the API, useful when getting a single record
---
- parameter_name: no-gh
- parameter_type: switch
- is_optional: true
- description: force to use `http get` instead of `gh`

## Signatures
| input     | output |
| --------- | ------ |
| `nothing` | `any`  |
