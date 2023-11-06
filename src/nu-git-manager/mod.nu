use std log

use fs/store.nu [get-repo-store-path, list-repos-in-store]
use fs/cache.nu [
    get-repo-store-cache-path, check-cache-file, add-to-cache, remove-from-cache, open-cache,
    save-cache, clean-cache-dir
]
use git/url.nu [parse-git-url, get-fetch-push-urls]
use git/repo.nu [is-grafted, get-root-commit]
use error/error.nu [throw-error]

def "nu-complete git-protocols" []: nothing -> table<value: string, description: string> {
    [
        [value, description];

        ["https", "use the HTTP protocol: will require a PAT authentification for private repositories"],
        ["ssh", "use the SSH protocol: will require a passphrase unless setup otherwise"],
        ["git", "use the GIT protocol: useful when cloning a *Suckless* repo"],
    ]
}

# manage your Git repositories with the main command of `nu-git-manager`
#
# `nu-git-manager` will look for a store in the following places, in order:
# - `$env.GIT_REPOS_HOME`
# - `$env.XDG_DATA_HOME | path join "repos"
# - `~/.local/share/repos`
#
# `nu-git-manager` will look for a cache in the following places, in order:
# - `$env.GIT_REPOS_CACHE`
# - `$env.XDG_CACHE_HOME | path join "nu-git-manager/cache.nuon"
# - `~/.cache/nu-git-manager/cache.nuon`
#
# # Examples
#     a contrived example, assuming you are in `~`
#     > GIT_REPOS_HOME=foo gm status | get root.path
#     ~/foo
#
#     a contrived example, assuming you are in `~`
#     > XDG_CACHE_HOME=foo gm status | get cache.path
#     ~/foo/nu-git-manager/cache.nuon
export def "gm" []: nothing -> nothing {
    print (help gm)
}

# clone a remote Git repository into your local store
#
# will give a nice error if the repository is already in the local store.
#
# # Examples
#     clone a repository in the local store of `nu-git-manager`
#     > gm clone https://github.com/amtoine/nu-git-manager
#
#     clone as a bare repository, i.e. a repo without a worktree
#     > gm clone --bare https://github.com/amtoine/nu-git-manager
#
#     clone a repo and change the name of the remote
#     > gm clone --remote default https://github.com/amtoine/nu-git-manager
#
#     setup a public repo in the local store and use HTTP to fetch without PAT and push with SSH
#     > gm clone https://github.com/amtoine/nu-git-manager --fetch https --push ssh
#
#     clone a big repo as a single commit, avoiding all intermediate Git deltas
#     > gm clone https://github.com/neovim/neovim --depth 1
export def "gm clone" [
    url: string # the URL to the repository to clone, supports HTTPS and SSH links, as well as references ending in `.git` or starting with `git@`
    --remote: string = "origin" # the name of the remote to setup
    --ssh # setup the remote to use the SSH protocol both to FETCH and to PUSH
    --fetch: string@"nu-complete git-protocols" # setup the FETCH protocol explicitely, will overwrite `--ssh` for FETCH
    --push: string@"nu-complete git-protocols" # setup the PUSH protocol explicitely, will overwrite `--ssh` for PUSH
    --bare # clone the repository as a "bare" project
    --depth: int # the depth at which to clone the repository
]: nothing -> nothing {
    let repository = $url | parse-git-url

    let local_path = get-repo-store-path
        | append [$repository.host $repository.owner $repository.group $repository.repo]
        | compact
        | path join

    if ($local_path | path exists) {
        throw-error {
            msg: "repository_already_in_store"
            label: {
                text: (
                    "this repository has already been cloned by "
                 + $"(ansi {fg: "default_dimmed", attr: "it"})gm(ansi reset)"
                )
                span: (metadata $url | get span)
            }
        }
    }

    let urls = get-fetch-push-urls $repository $fetch $push $ssh

    mut args = [$urls.fetch $local_path --origin $remote]
    if $depth != null {
        if ($depth < 1) {
            throw-error {
                msg: "invalid_clone_depth"
                label: {
                    text: $"clone depth should be strictly positive, found ($depth)"
                    span: (metadata $depth | get span)
                }
            }
        }

        $args = ($args ++ --depth ++ $depth)

        if $bare {
            $args = ($args ++ --bare)
        }
    } else {
        if $bare {
            $args = ($args ++ --bare)
        }
    }

    ^git clone $args

    ^git -C $local_path remote set-url $remote $urls.fetch
    ^git -C $local_path remote set-url $remote --push $urls.push

    let cache_file = get-repo-store-cache-path
    check-cache-file $cache_file
    add-to-cache $cache_file {
        path: $local_path,
        grafted: (is-grafted $local_path),
        root: (get-root-commit $local_path)
    }

    null
}

# list all the local repositories in your local store
#
# /!\ this command will return sanitized paths. /!\
#
# # Examples
#     list all the repositories in the store
#     > gm list
#
#     list all the repositories in the store with their full paths
#     > gm list --full-path
#
#     jump to a directory in the store
#     > cd (gm list --full-path | input list)
export def "gm list" [
    --full-path # show the full path instead of only the "owner + group + repo" name
]: nothing -> list<path> {
    let cache_file = get-repo-store-cache-path
    check-cache-file $cache_file

    if $full_path {
        open-cache $cache_file | get path
    } else {
        open-cache $cache_file | get path | each {
            str replace (get-repo-store-path) '' | str trim --left --char "/"
        }
    }
}

# get current status about the repositories managed by `nu-git-manager`
#
# /!\ `$.root.path` and `$.cache.path` will be sanitized /!\
#
# Examples
#     getting status when everything is fine
#     > gm status | reject missing | flatten | into record
#     ╭─────────────────────┬────────────────────────────────────╮
#     │ path                │ ~/.local/share/repos               │
#     │ exists              │ true                               │
#     │ cache_path          │ ~/.cache/nu-git-manager/cache.nuon │
#     │ cache_exists        │ true                               │
#     │ should_update_cache │ false                              │
#     ╰─────────────────────┴────────────────────────────────────╯
#
#     getting status when there is no store
#     > gm status | get root
#     ╭────────┬──────────────────────╮
#     │ path   │ ~/.local/share/repos │
#     │ exists │ false                │
#     ╰────────┴──────────────────────╯
#
#     getting status when there is no cache
#     > gm status | get root
#     ╭────────┬────────────────────────────────────╮
#     │ path   │ ~/.cache/nu-git-manager/cache.nuon │
#     │ exists │ false                              │
#     ╰────────┴────────────────────────────────────╯
#
#     getting status when a project is in the cache but is missing on the filesystem
#     > gm status | get missing
#     ╭──────────────────────────────────────╮
#     │ 0 │ ~/.local/share/repos/foo/bar/baz │
#     ╰──────────────────────────────────────╯
#
#     update the cache if necessary
#     > if (gm status).should_update_cache { gm update-cache }
export def "gm status" []: nothing -> record<root: record<path: path, exists: bool>, missing: list<path>, cache: record<path: path, exists: bool>, should_update_cache: bool> {
    let root = get-repo-store-path
    let cache = get-repo-store-cache-path

    let cache_exists = ($cache | path type) == "file"

    let missing = if $cache_exists {
        open-cache $cache | where ($it | path type) != "dir"
    } else {
        null
    }

    {
        root: {
            path: $root
            exists: (($root | path type) == "dir")
        }
        missing: $missing
        cache: {
            path: $cache
            exists: $cache_exists
        }
        should_update_cache: ((not ($missing | is-empty)) or (not $cache_exists))
    }
}

# update the local cache of repositories
#
# # Examples
#     update the cache of repositories
#     > gm update-cache
export def "gm update-cache" []: nothing -> nothing {
    let cache_file = get-repo-store-cache-path
    clean-cache-dir $cache_file

    print --no-newline "updating cache... "
    list-repos-in-store | each {{
        path: $in,
        grafted: (is-grafted $in),
        root: (get-root-commit $in)
    }} | save-cache $cache_file
    print "done"

    null
}

# remove one of the repositories from your local store
#
# # Examples
#     remove any repository by fuzzy-finding the whole store
#     > gm remove --fuzzy
#
#     restrict the search to any one of my repositories
#     > gm remove amtoine
#
#     remove a precise repo by giving its full name, a name collision is unlikely
#     > gm remove amtoine/nu-git-manager
export def "gm remove" [
    pattern?: string # a pattern to restrict the choices
    --fuzzy # remove after fuzzy-finding the repo(s) to clean
]: nothing -> nothing {
    let root = get-repo-store-path
    let choices = gm list
        | each {
            str replace $root '' | str trim --left --char "/"
        }
        | find $pattern

    let repo_to_remove = match ($choices | length) {
        0 => {
            throw-error {
                msg: "no_matching_repository"
                label: {
                    text: (
                        "no repository matching this in "
                     + $"(ansi {fg: "default_dimmed", attr: "it"})($root)(ansi reset)"
                    )
                    span: (metadata $pattern | get span)
                }
            }
        },
        1 => { $choices | first },
        _ => {
            let prompt = $"please choose a repository to (ansi red)remove(ansi reset)"
            let choice = if $fuzzy {
                $choices | input list --fuzzy $prompt
            } else {
                $choices | input list $prompt
            }

            if ($choice | is-empty) {
                log info "user chose to exit"
                return
            }

            $choice
        },
    }

    let prompt = $"are you (ansi defu)sure(ansi reset) you want to (ansi red_bold)remove(ansi reset) (ansi yellow)($repo_to_remove)(ansi reset)? "
    match (["no", "yes"] | input list $prompt) {
        "no" => {
            log info $"user chose to (ansi green_bold)keep(ansi reset) (ansi yellow)($repo_to_remove)(ansi reset)"
            return
        },
        "yes" => { rm --recursive --force --verbose ($root | path join $repo_to_remove) },
    }

    let cache_file = get-repo-store-cache-path
    check-cache-file $cache_file
    remove-from-cache $cache_file ($root | path join $repo_to_remove)

    null
}
