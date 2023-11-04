use std log
use path.nu "path sanitize"

# get the root of the local repo store
#
# /!\ this command will sanitize the output path. /!\
export def get-repo-store-path []: nothing -> path {
    $env.GIT_REPOS_HOME? | default (
        $env.XDG_DATA_HOME? | default ($nu.home-path | path join ".local/share") | path join "repos"
    ) | path expand | path sanitize
}

# list all the repos stored locally
#
# this command will return the empty list if the store does not exist.
#
# this command will
# - catch *bare* repositories
# - remove duplicates coming from nested repositories such as Git submodules
#
# /!\ this command will sanitize the output list of paths. /!\
export def list-repos-in-store []: nothing -> list<path> {
    if not (get-repo-store-path | path exists) {
        log debug $"the store does not exist: `(get-repo-store-path)`"
        return []
    }

    # FIXME: glob does not work very well with Windows and absolute paths: the easy fix is to `cd`
    # first and then perform the globbing
    # related to https://github.com/nushell/nushell/issues/7125
    cd (get-repo-store-path)
    let heads: list<string> = glob "**/HEAD" --not [
            **/.git/**/refs/remotes/**/HEAD,
            **/.git/modules/**/HEAD,
            **/logs/HEAD
        ]
    # NOTE: we need to keep the trailing `/` here to avoid telling that `foo.bar` is a duplicate of
    # `foo`, because `foo/` is not contained in `foo.bar/`
    let repos = $heads | each { path sanitize } | str replace --regex '(.git/)?HEAD$' ''

    let sorted = $repos | sort
    let pairs = $sorted | range 1.. | zip ($sorted | range ..(-2))
    $pairs
        | filter {|it| not ($it.0 | str starts-with $it.1)}
        | each { get 0 }
        | prepend $sorted.0
        | str trim --right --char "/"
}
