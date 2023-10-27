use path.nu "path sanitize"

export def get-repo-store-cache-path []: nothing -> path {
    $env.GIT_REPOS_CACHE?
        | default (
            $env.XDG_CACHE_HOME?
                | default ($nu.home-path | path join ".cache")
                | path join "nu-git-manager/cache.nuon"
        )
        | path expand
        | path sanitize
}

export def check-cache-file [cache_file: path]: nothing -> nothing {
    if not ($cache_file | path exists) {
        error make --unspanned {
            msg: (
                $"(ansi red_bold)cache_not_found(ansi reset):\n"
              + $"please run `(ansi default_dimmed)gm update-cache(ansi reset)` to create the cache"
            )
        }
    }
}
