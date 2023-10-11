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
}

export def list-repos-in-store []: nothing -> list<path> {
    if not (get-repo-store-path | path exists) {
        return []
    }

    let res: list<string> = glob ($env.GIT_REPOS_HOME | path join "**/HEAD") --not [
            **/.git/**/refs/remotes/**/HEAD,
            **/.git/modules/**/HEAD,
            **/logs/HEAD
        ]

    $res | str replace --regex '/(.git/)?HEAD$' ''
}
