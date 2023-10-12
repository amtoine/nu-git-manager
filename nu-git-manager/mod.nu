use std log

use fs/store.nu [get-repo-store-path, get-repo-store-cache-path, list-repos-in-store]
use git/url.nu [parse-git-url, get-fetch-push-urls]

def "nu-complete git-protocols" []: nothing -> table<value: string, description: string> {
    [
        [value, description];

        ["https", "use the HTTP protocol: will require a PAT authentification for private repositories"],
        ["ssh", "use the SSH protocol: will require a passphrase unless setup otherwise"],
    ]
}

# manage your Git repositories with the main command of `nu-git-manager`
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
export def "gm clone" [
    url: string # the URL to the repository to clone, supports HTTPS and SSH links, as well as references ending in `.git` or starting with `git@`
    --remote: string = "origin" # the name of the remote to setup
    --ssh # setup the remote to use the SSH protocol both to FETCH and to PUSH
    --fetch: string@"nu-complete git-protocols" # setup the FETCH protocol explicitely, will overwrite `--ssh` for FETCH
    --push: string@"nu-complete git-protocols" # setup the PUSH protocol explicitely, will overwrite `--ssh` for PUSH
    --bare # clone the repository as a "bare" project
]: nothing -> nothing {
    let repository = $url | parse-git-url

    let local_path = get-repo-store-path
        | append [$repository.host $repository.owner $repository.group $repository.repo]
        | compact
        | path join

    if ($local_path | path exists) {
        let span = metadata $url | get span
        error make {
            msg: $"(ansi red_bold)repository_already_in_store(ansi reset)"
            label: {
                text: $"this repository has already been cloned by (ansi {fg: "default_dimmed", attr: "it"})gm(ansi reset)"
                start: $span.start
                end: $span.end
            }
        }
    }

    let urls = get-fetch-push-urls $repository $fetch $push $ssh

    if $bare {
        git clone $urls.fetch $local_path --origin $remote --bare
    } else {
        git clone $urls.fetch $local_path --origin $remote
    }

    git -C $local_path remote set-url $remote $urls.fetch
    git -C $local_path remote set-url $remote --push $urls.push

    gm list --update

    null
}

# list all the local repositories in your local store
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
#
#     update the cache of repositories
#     > gm list --update
export def "gm list" [
    --full-path # show the full path instead of only the "owner + group + repo" name
    --update # will dump the content of the store to the cache of `nu-git-manager`
]: nothing -> list<path> {
    let cache_file = get-repo-store-cache-path

    if $update {
        rm --recursive --force $cache_file
        mkdir ($cache_file | path dirname)

        print --no-newline "updating cache... "
        list-repos-in-store | save --force $cache_file
        print "done"

        return
    }

    if not ($cache_file | path exists) {
        error make --unspanned {
            msg: (
                $"(ansi red_bold)cache_not_found(ansi reset):\n"
              + $"please run `(ansi default_dimmed)gm list --update(ansi reset)` to create the cache"
            )
        }
    }

    let repos = open $cache_file
    if $full_path {
        $repos
    } else {
        $repos | each {
            str replace (get-repo-store-path) '' | str trim --left --char (char path_sep)
        }
    }
}

# get the root of the local store of repositories managed by `nu-git-manager`
#
# `nu-git-manager` will look for a store in the following places, in order:
# - `$env.GIT_REPOS_HOME`
# - `$env.XDG_DATA_HOME | path join "repos"
# - `~/.local/share/repos`
#
# # Example
#     a contrived example, assuming you are in `~`
#     > GIT_REPOS_HOME=foo gm root
#     ~/foo
export def "gm root" []: nothing -> path {
    get-repo-store-path
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
            str replace $root '' | str trim --left --char (char path_sep)
        }
        | find $pattern

    let repo_to_remove = match ($choices | length) {
        0 => {
            let span = metadata $pattern | get span
            error make {
                msg: $"(ansi red_bold)no_matching_repository(ansi reset)"
                label: {
                    text: $"no repository matching this in (ansi {fg: "default_dimmed", attr: "it"})($root)(ansi reset)"
                    start: $span.start
                    end: $span.end
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
        "no" => { log info $"user chose to (ansi green_bold)keep(ansi reset) (ansi yellow)($repo_to_remove)(ansi reset)" },
        "yes" => { rm --recursive --force --verbose ($root | path join $repo_to_remove) },
    }

    gm list --update

    null
}
