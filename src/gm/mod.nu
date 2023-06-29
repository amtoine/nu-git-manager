use std log
use utils/utils.nu [
    "get root dir"
    "parse project"
    "default project"
    "pick repo"
    "list repos"
]

# fuzzy-jump to any repository managed by `gm`
export def-env goto [
    query?: string  # a search query to narrow down the list of choices
] {
    let choice = (pick repo
        $"Please (ansi yellow_italic)choose a repo(ansi reset) to (ansi green_underline)jump to:(ansi reset)"
        $query
    )
    if ($choice | is-empty) {
        return
    }

    cd (get root dir | path join $choice)
}

# fuzzy-delete any repository managed by `gm`
export def remove [
    query?: string      # a search query to narrow down the list of choices
    --force (-f): bool  # do not ask for comfirmation when deleting a repository
] {
    let choice = (pick repo
        $"Please (ansi yellow_italic)choose a repo(ansi reset) to (ansi red_underline)completely remove:(ansi reset)"
        $query
    )
    if ($choice | is-empty) {
        return
    }

    let repo = (get root dir | path join $choice)
    if $force {
        rm --trash --verbose --recursive $repo
    } else {
        rm --trash --verbose --recursive $repo --interactive
    }
}

# TODO: add support for other hosts than github
# TODO: better worktree support

# Clone a repository into a standard location
#
# This place is organised by domain and path.
export def grab [
    project: string               # <repository URL>|<host>/<user>/<project>|<user>/<project>|<project>
    --ssh (-p): bool              # use ssh instead of https.
    --bare (-b): bool             # clone as *bare* repo (specific to worktrees).
    --update (-u): bool           # not supported
    --shallow (-s): bool          # not supported
    --branch: bool                # not supported
    --no-recursive: bool          # not supported
    --look: bool                  # not supported
    --silent: bool                # not supported
    --vcs (-v): string            # not supported
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
    if ($vcs | is-empty) {
        log debug "`--vcs` option is NOT SUPPORTED in `gm grab`"
    }

    let project = (
        parse project $project
        | default project
        | update project { str replace --all '\/' '-'}
    )

    let url = if $ssh {
        $"git@($project.host):($project.user)/($project.project).git"
    } else {
        $"https://($project.host)/($project.user)/($project.project).git"
    }

    let local = (get root dir | path join $project.host $project.user $project.project)

    if $bare {
        git clone --bare --recurse-submodules $url $local
    } else {
        git clone --recurse-submodules $url $local
    }
}

# list locally-cloned repositories
#
# by default `gm list` only searches the three first depth levels:
# - host
# - user
# - project
export def list [
    query?: string          # return only repositories matching the query
    --exact (-e): bool      # force the match to be exact, i.e. the query equals to project, user/project or host/user/project
    --full-path (-p): bool  # return the full paths instead of path relative to the `gm` root
    --recursive: bool       # perform a recursive search of all `.git/` directories
] {(
    list repos $query
        --exact $exact
        --full-path $full_path
        --recursive $recursive
)}

# print the root of the repositories
export def root [
    --all (-a): bool  # not supported
] {
    if $all {
        log debug "`--all` option is NOT SUPPORTED in `gm root`"
    }

    get root dir
}

# create a new repository
export def create [
    repository: string  # <repository URL>|<host>/<user>/<project>|<user>/<project>|<project>
    --vcs (-v): string  # not supported
] {
    if ($vcs | is-empty) {
        log debug "`--vcs` option is NOT SUPPORTED in `gm create`"
    }

    # TODO: implement `gm create`
    log warning "COMING SOON"
}

# the `nu-[g]it-[m]anager`, a WIP to manage any `git` repo in a centralized store, with sugar on top
export def main [] { help gm }
