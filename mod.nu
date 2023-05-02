use std ['log debug', 'log warning']

def root_dir [] {
    $env.GIT_REPOS_HOME? | default ($nu.home-path | path join "dev")
}

# TODO: support cancel
def lsi [path: string = "."] {(
    ls $path
    | get name
    | to text
    | gum choose --no-limit
    | lines
    | get 1 | str trim    # hack to suppress the errors
)}

export def-env "gm ungrab" [] {
    # TODO: ungrab should move to a trash folder!
    ls -s (root_dir) | gum choose
}

export def-env "gm grab select" [] {
    let owner = (lsi (root_dir))
    let repo = (lsi $owner)

    cd $repo
}

# TODO: add support for other hosts than github
# TODO: better worktree support

# Clone a repository into a standard location
#
# This place is organised by domain and path.
export def "gm grab" [
    owner: string                 # the name of the owner of the repo.
    repo: string                  # the name of the repo to grab.
    --host: string = "github.com" # the host to grab the repo from.
    --ssh (-p): bool              # use ssh instead of https.
    --bare (-b): bool             # clone as *bare* repo (specific to worktrees).
    --update (-u): bool           # not supported
    --shallow (-s): bool          # not supported
    --branch: bool                # not supported
    --no-recursive: bool          # not supported
    --look: bool                  # not supported
    --silent: bool                # not supported
    --vcs (-v): bool              # not supported
] {
    # TODO: implement `--update` option
    if $update {
        log warning "`--update` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--shallow` option
    if $shallow {
        log warning "`--shallow` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--branch` option
    if $branch {
        log warning "`--branch` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--look` option
    if $look {
        log warning "`--look` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--silent` option
    if $silent {
        log warning "`--silent` option for `gm grab` COMING SOON"
    }
    # TODO: implement `--no-recursive` option
    if $no_recursive {
        log warning "`--no-recursive` option for `gm grab` COMING SOON"
    }
    if $vcs {
        log debug "`--vcs` option is NOT SUPPORTED in `gm grab`"
    }

    let url = (if $ssh {
        $"git@($host):($owner)/($repo).git"
    } else {
        $"https://($host)/($owner)/($repo).git"
    })

    let local = (root_dir | path join $host $owner $repo)

    if $bare {
        git clone --bare --recurse-submodules $url $local
    } else {
        git clone --recurse-submodules $url $local
    }
}

# list locally-cloned repositories
export def "gm list repos" [
    query?: string          # return only repositories matching the query
    --exact (-e): bool      # force the match to be exact, i.e. the query equals to project, user/project or host/user/project
    --full-path (-p): bool  # return the full paths instead of path relative to the `gm` root
] {
    let root = (root_dir)
    let repos = (
        ls ($root | path join "**" "*" ".git")
        | get name
        | path parse
        | get parent
        | str replace $root ""
        | str trim -l -c (char path_sep)
        | parse "{host}/{user}/{project}"
        | insert user-project {|it| [$it.user $it.project] | path join}
        | insert host-user-project {|it| [$it.host $it.user $it.project] | path join}
    )

    let repos = ($repos | if $query != null {
        if $exact {
            where {|it| (
                ($it.project == $query) or
                ($it.user-project == $query) or
                ($it.host-user-project == $query)
            )}
        } else {
            find $query
        }
    } else {})

    $repos | get host-user-project | if $full_path {
        each {|repo| $root | path join $repo}
    } else {}
}

# print the root of the repositories
export def "gm root" [
    --all (-a): bool  # not supported
] {
    if $all {
        log debug "`--all` option is NOT SUPPORTED in `gm root`"
    }

    root_dir
}

# create a new repository
export def "gm create" [
    repository: string
    --vcs (-v): bool  # not supported
] {
    if $vcs {
        log debug "`--vcs` option is NOT SUPPORTED in `gm create`"
    }

    # TODO: implement `gm create`
    log warning "COMING SOON"
}
