# `nu-git-manager gm`
## Description
manage your Git repositories with the main command of `nu-git-manager`
`nu-git-manager` will look for a store in the following places, in order:
- `$env.GIT_REPOS_HOME`
- `$env.XDG_DATA_HOME | path join "repos"
- `~/.local/share/repos`

`nu-git-manager` will look for a cache in the following places, in order:
- `$env.GIT_REPOS_CACHE`
- `$env.XDG_CACHE_HOME | path join "nu-git-manager/cache.nuon"
- `~/.cache/nu-git-manager/cache.nuon`

# Examples
    a contrived example to set the path to the root of the store
    > with-env { GIT_REPOS_HOME: ($nu.home-path | path join "foo") } {
          gm status | get root.path | str replace $nu.home-path '~'
      }
    ~/foo

    a contrived example to set the path to the cache of the store
    > with-env { XDG_CACHE_HOME: ($nu.home-path | path join "foo") } {
          gm status | get cache.path | str replace $nu.home-path '~'
      }
    ~/foo/nu-git-manager/cache.nuon

## Signature
| input   | output  |
| ------- | ------- |
| nothing | nothing |
