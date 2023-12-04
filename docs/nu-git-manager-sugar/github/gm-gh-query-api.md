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

## Signature
| input     | output |
| --------- | ------ |
| `nothing` | `any`  |
