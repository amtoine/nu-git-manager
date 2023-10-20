use path.nu "path sanitize"

export def get-repo-store-path []: nothing -> path {
    $env.GIT_REPOS_HOME? | default (
        $env.XDG_DATA_HOME? | default ($nu.home-path | path join ".local/share") | path join "repos"
    ) | path expand | path sanitize
}

export def list-repos-in-store []: nothing -> list<path> {
    if not (get-repo-store-path | path exists) {
        return []
    }

    if $nu.os-info.name == "windows" {
        # FIXME: this is super slow on windows
        glob **/*.git --not [**/*.venv **/node_modules/** **/target/** **/build/** */]
    } else {
        # FIXME: do not use external `find` command
        ^find (get-repo-store-path) -name ".git"
            | lines
    }  | each { path split | range 0..(-2) | path join }
}
