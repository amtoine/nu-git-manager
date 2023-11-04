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

export def open-cache [cache_file: path]: nothing -> list<path> {
    open --raw $cache_file | from nuon
}

export def save-cache [cache_file: path]: list<path> -> nothing {
    to nuon | save --force $cache_file
}

export def add-to-cache [cache_file: path, new_path: path]: nothing -> nothing {
    print --no-newline "updating cache... "
    open-cache $cache_file | append $new_path | uniq | sort | save-cache $cache_file
    print "done"
}

export def remove-from-cache [cache_file: path, old_path: path]: nothing -> nothing {
    print --no-newline "updating cache... "
    open-cache $cache_file | where $it != $old_path | save-cache $cache_file
    print "done"
}

export def clean-cache-dir [cache_file: path]: nothing -> nothing {
    rm --recursive --force $cache_file
    mkdir ($cache_file | path dirname)
}
