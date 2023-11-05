use path.nu "path sanitize"
use ../git/repo.nu [is-grafted]

# get the path to the cache of the local store of repos
#
# /!\ this command will sanitize the output path. /!\
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

# make sure the cache file exists and give a nice error otherwise
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

# open the cache file
#
# /!\ this command will return sanitized paths if `add-to-cache` or `gm update-cache` have been used. /!\
export def open-cache [cache_file: path]: nothing -> table<path: path, grafted: bool, root: string> {
    open --raw $cache_file | from nuon
}

# save a list of paths to the cache file
#
# /!\ this command will sanitize the paths for the caller. /!\
export def save-cache [cache_file: path]: table<path: path, grafted: bool, root: string> -> nothing {
    update path { path sanitize } | to nuon | save --force $cache_file
}

# add a new path to the cache file
#
# /!\ this command will sanitize the paths for the caller. /!\
export def add-to-cache [
    cache_file: path,
    repo: record<path: string, grafted: bool, root: string>
]: nothing -> nothing {
    print --no-newline "updating cache... "
    open-cache $cache_file
        | append $repo
        | uniq
        | sort
        | save-cache $cache_file
    print "done"
}

# remove an old path from the cache file
#
# /!\ this command will sanitize the paths for the caller. /!\
export def remove-from-cache [cache_file: path, old_path: path]: nothing -> nothing {
    print --no-newline "updating cache... "
    open-cache $cache_file | where $it.path != ($old_path | path sanitize) | save-cache $cache_file
    print "done"
}

# clean and prepare the cache directory
#
# this command will
# - remove any previous cache file: this avoids having an invalid file, e.g. a directory, in the
#  same place as the expected cache file
# - create the parent directory of the cache file
export def clean-cache-dir [cache_file: path]: nothing -> nothing {
    rm --recursive --force $cache_file
    mkdir ($cache_file | path dirname)
}
