use std log
use path.nu "path sanitize"

export def get-repo-store-path []: nothing -> path {
    $env.GIT_REPOS_HOME? | default (
        $env.XDG_DATA_HOME? | default ($nu.home-path | path join ".local/share") | path join "repos"
    ) | path expand | path sanitize
}

export def get-repo-store-cache-path []: nothing -> path {
    $env.XDG_CACHE_HOME?
        | default ($nu.home-path | path join ".cache")
        | path join "nu-git-manager/cache.nuon"
        | path expand
        | path sanitize
}

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
