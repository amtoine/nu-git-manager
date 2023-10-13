export def get-repo-store-path []: nothing -> path {
    $env.GIT_REPOS_HOME? | default (
        $env.XDG_DATA_HOME? | default ($nu.home-path | path join ".local/share") | path join "repos"
    ) | path expand
}

export def list-repos-in-store []: nothing -> list<path> {
    if not (get-repo-store-path | path exists) {
        return []
    }

    # FIXME: do not use external `find` command
    ^find (get-repo-store-path) -name ".git"
        | lines
        | each { path split | range 0..(-2) | path join }
}
